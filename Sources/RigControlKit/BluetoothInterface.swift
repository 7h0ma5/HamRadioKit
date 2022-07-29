//
//  Bluetooth.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 26.06.22.
//

import Foundation
import CoreBluetooth
import AsyncAlgorithms
import os
#if os(iOS)
import UIKit
#endif

@objc
class BluetoothInterface: NSObject, TransceiverInterface, ObservableObject {
    var events: TransceiverInterfaceEventChannel

    let connectionId: UUID
    let serviceId = CBUUID(string: "14CF8001-1EC2-D408-1B04-2EB270F14203")
    let characteristicId = CBUUID(string: "14CF8002-1EC2-D408-1B04-2EB270F14203")

    private var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var service: CBService?
    var characteristic: CBCharacteristic?
    var descriptor: CBDescriptor?

    var commandContinuation: CheckedContinuation<Data?, Error>?

    var status: TransceiverInterfaceStatus = .disconnected {
        didSet {
            Task {
                await self.events.send(.statusUpdated(self.status))
            }
        }
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: BluetoothInterface.self)
    )

    required init(connectionId: UUID) {
        self.connectionId = connectionId
        self.events = TransceiverInterfaceEventChannel()

        super.init()

        centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }

    func command(_ cmd: Data) async throws -> Data? {
        guard status == .connected,
           let peripheral = peripheral,
           let characteristic = characteristic,
           characteristic.isNotifying
        else { throw TransceiverInterfaceError() }

        Self.logger.trace("Writing \((cmd as NSData).debugDescription)")

        return try await withCheckedThrowingContinuation { continuation in
            commandContinuation = continuation
            peripheral.writeValue(cmd, for: characteristic, type: .withResponse)
        }
    }
}

extension BluetoothInterface: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {

        guard let services = peripheral.services else {
            return
        }

        Self.logger.debug("Found services: \(services.debugDescription)")
        error.map { Self.logger.error("\($0.localizedDescription)") }

        guard let service = services.first(where: { $0.uuid == serviceId }) else { return }

        peripheral.discoverCharacteristics([characteristicId], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        Self.logger.debug("Found characteristics: \(service.characteristics.debugDescription)")
        error.map { Self.logger.error("\($0.localizedDescription)") }

        guard let characteristics = service.characteristics else {
            return
        }

        guard let characteristic = characteristics.first(where: { $0.uuid == characteristicId }) else { return }

        self.characteristic = characteristic

        peripheral.setNotifyValue(true, for: characteristic)

        Self.logger.info("Sending identification...")

        let uuid = withUnsafePointer(to: self.connectionId.uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: self.connectionId.uuid))
        }

        peripheral.writeValue(Data([0xFE, 0xF1, 0x00, 0x61] + uuid + [0xFD]), for: characteristic, type: .withResponse)

        // peripheral.discoverDescriptors(for: characteristic)
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverDescriptorsFor characteristic: CBCharacteristic,
                    error: Error?) {

        guard let descriptors = characteristic.descriptors else {
            return
        }

        guard let descriptor = descriptors.first else { return }

        self.descriptor = descriptor
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {

        assert(self.characteristic == characteristic)
        Self.logger.debug("Notification status updated for \(characteristic.debugDescription).")
        error.map { Self.logger.error("\($0.localizedDescription)") }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        Self.logger.trace("Value written: \(characteristic.value.map { ($0 as NSData).debugDescription } ?? "")")
        error.map { Self.logger.error("\($0.localizedDescription)") }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {

        Self.logger.trace("Value received: \(characteristic.value.map { ($0 as NSData).debugDescription } ?? "")")

        error.map { Self.logger.error("\($0.localizedDescription)") }

        guard error == nil else {
            return
        }

        guard let data = characteristic.value.map([UInt8].init) else { return }
        var slice = data[...]

        while slice.starts(with: [0xfe, 0xfe]) {
            let cmd = slice.prefix(while: { $0 != 0xfd }) + [0xfd]
            slice = slice.dropFirst(cmd.count)

            peripheral.writeValue(Data([0xfe, 0xf1, 0x00, 0x60, 0xfb, 0xfd]),
                                  for: characteristic, type: .withoutResponse)

            if let commandContinuation = commandContinuation {
                commandContinuation.resume(returning: Data(cmd))
                self.commandContinuation = nil
            }
            else {
                Task {
                    await self.events.send(.dataReceived(Data(cmd)))
                }
            }
        }

        if data.starts(with: [0xfe, 0xf1, 0x00]) && data.count > 3 {
            switch data[3] {
            case 0x62:
                Self.logger.debug("Handle identification request (0x62)")

                var name = "QLog"

                #if os(iOS)
                switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    name = "QLog on iPhone"
                case .pad:
                    name = "QLog on iPad"
                case .mac:
                    name = "QLog on macOS"
                default:
                    name = "QLog"
                }
                #elseif os(macOS)
                name = "QLog on macOS"
                #endif

                let id = Data(name.padding(toLength: 16, withPad: " ", startingAt: 0).utf8)

                peripheral.writeValue([0xfe, 0xf1, 0x00, 0x62] + id + [0xfd],
                                      for: characteristic, type: .withResponse)

            case 0x63:
                Self.logger.debug("Handle connection request (0x63)")
                peripheral.writeValue(Data([0xfe, 0xf1, 0x00, 0x63, 0x0b, 0xa3, 0x98, 0x3c, 0xfd]),
                                      for: characteristic, type: .withResponse)
                return

            case 0x64:
                Self.logger.info("Connection successful!")
                self.status = .connected
                return

            default:
                Self.logger.warning("Unknown Bluetooth LE command: \(data.debugDescription)")
            }
        }
    }
}

extension BluetoothInterface: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Self.logger.debug("Bluetooth status updated: \(central.state.rawValue)")

        switch central.state {
        case .poweredOn:
            Self.logger.info("Starting scan for peripherals!")
            centralManager.scanForPeripherals(withServices: [serviceId], options: nil)
            self.status = .connecting
        case .poweredOff:
            self.status = .disconnected
        case .unauthorized:
            self.status = .disconnected
        case .unsupported:
            self.status = .disconnected
        case .resetting:
            self.status = .disconnected
        case .unknown:
            self.status = .disconnected
        default:
            Self.logger.warning("Unknown Bluetooth state: \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

        Self.logger.debug("Discovered \(peripheral.debugDescription), RSSI: \(RSSI.debugDescription)")

        peripheral.delegate = self
        self.peripheral = peripheral

        self.centralManager.stopScan()

        Self.logger.info("Trying to connect \(peripheral.name.debugDescription) \(peripheral.identifier)...")
        centralManager.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {

        Self.logger.warning("Bluetooth failed to connect!")
        error.map { Self.logger.error("\($0.localizedDescription)") }

        assert(peripheral == self.peripheral!)

        self.status = .disconnected
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Self.logger.info("Bluetooth device connected!")

        assert(peripheral == self.peripheral!)

        peripheral.discoverServices([serviceId])
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {

        Self.logger.info("Bluetooth device disconnected!")
        error.map { Self.logger.error("\($0.localizedDescription)") }

        self.peripheral = nil
        self.service = nil
        self.characteristic = nil
        self.descriptor = nil

        self.status = .disconnected
    }
}

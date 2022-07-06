//
//  IcomTransceiver.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation

class IcomTransceiverConnection: TransceiverControl {
    var interface: any TransceiverInterface
    
    let ctrlAddress: UInt8 = 0xe0
    let trxAddress: UInt8 = 0xa4

    init(interface: any TransceiverInterface) {
        self.interface = interface
        self.interface.onCommand = self.onCommand
    }
        
    func command(_ cmd: [UInt8], data: [UInt8]?) async throws -> [UInt8] {
        let commandBytes: [UInt8] = [
            0xfe, 0xfe,
            trxAddress, ctrlAddress,
        ] +  cmd + (data ?? []) + [0xfd];
        
        let response = try await interface.command(Data(commandBytes))
        
        return [UInt8](response)
    }
    
    func onCommand(data: Data) {
        guard data.starts(with: [0xfe, 0xfe]) && data.count >= 5 else {
            debugPrint("Invalid CI-V command")
            return
        }
        
        // Check target address (our address or broadcast)
        guard data[2] == self.ctrlAddress || data[2] == 0 else {
            debugPrint("Received CI-V command for other recipient")
            return
        }
        
        // Check soruce address
        guard data[3] == self.trxAddress else {
            debugPrint("Received CI-V command from unknown source")
            return
        }
        
        switch data[4] {
        case 0x00:
            let freq = Self.parseFrequency(from: [UInt8](data[5...9]))
            
        case 0x01:
            debugPrint("received mode data (transceive)")
            
        case 0x03:
            debugPrint("received the operating frequency")
            
        case 0x06:
            debugPrint("set the operating mode")
            
        default:
            debugPrint("unknown command", data[5])
        }
    }
    
    func change(frequency: Double) async throws {
    
    }
    
    func change(mode: TransceiverMode, sideband: TransceiverSideband) async throws {
        var result: [UInt8]

        switch (mode, sideband) {
        case (.ssb, .lsb):
            result = try await command([0x06], data: [0x00, 0x01])
        case (.ssb, .usb):
            result = try await command([0x06], data: [0x01, 0x01])
        case (.am, _):
            result = try await command([0x06], data: [0x02, 0x01])
        case (.fm, _):
            result = try await command([0x06], data: [0x05, 0x01])
        case (.cw, .usb):
            result = try await command([0x06], data: [0x03, 0x01])
        case (.cw, .lsb):
            result = try await command([0x06], data: [0x07, 0x01])
        case (.rtty, .usb):
            result = try await command([0x06], data: [0x04, 0x01])
        case (.rtty, .lsb):
            result = try await command([0x06], data: [0x08, 0x01])
        }
    }
    
    private func updateFrequency(freq: Frequency) async throws {
        try await command([0x03], data: Self.frequencyArray(for: freq))
    }
    
    private static func parseFrequency(from data: [UInt8]) -> Frequency? {
        guard data.count == 5 else { return nil }
        var result: Frequency = UInt64(data[0] & 0xF) * 1 + UInt64(data[0] >> 4) * 10
        result += UInt64(data[1] & 0xF) * 100 + UInt64(data[1] >> 4) * 1_000
        result += UInt64(data[2] & 0xF) * 10_000 + UInt64(data[2] >> 4) * 100_000
        result += UInt64(data[3] & 0xF) * 1_000_000 + UInt64(data[3] >> 4) * 10_000_000
        result += UInt64(data[4] & 0xF) * 100_000_000 + UInt64(data[4] >> 4) * 1_000_000_000
        return result
    }
    
    private static func frequencyArray(for frequency: Frequency) -> [UInt8] {
        return [
            UInt8(frequency % 1 / 1) | UInt8(frequency % 10 / 10) << 4 ,
            UInt8(frequency % 100 / 100) | UInt8(frequency % 1_000 / 1_000) << 4,
            UInt8(frequency % 10_000 / 10_000) | UInt8(frequency % 100_000 / 100_000) << 4,
            UInt8(frequency % 1_000_000 / 1_000_000) | UInt8(frequency % 10_000_000 / 10_000_000) << 4,
            UInt8(frequency % 100_000_000 / 100_000_000) | UInt8(frequency % 1_000_000_000 / 1_000_000_000) << 4
        ]
    }
}

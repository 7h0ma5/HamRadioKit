//
//  IcomTransceiver.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation
import AsyncAlgorithms

public class IcomTransceiverConnection: TransceiverControl {
    public var stateChannel = AsyncChannel(element: TransceiverState.self)
    private var state = TransceiverState()

    var interface: any TransceiverInterface
    var commandTask: Task<Void, Error>?

    let ctrlAddress: UInt8 = 0xe0
    let trxAddress: UInt8 = 0xa4

    init(interface: any TransceiverInterface) async {
        self.interface = interface

        self.commandTask = Task { [weak self] in
            for await cmd in interface.commands {
                if self == nil || Task.isCancelled { break }
                await self?.onCommand(data: cmd)
            }
        }
    }

    deinit {
        commandTask?.cancel()

        Task {
            self.state.status = .disconnected
            await self.stateChannel.send(self.state)
        }
    }

    public func connect() async throws {
        self.state.status = .connecting
        await self.stateChannel.send(self.state)

        try await self.interface.connect()
    }

    func command(_ cmd: [UInt8], data: [UInt8]?) async throws -> [UInt8] {
        let commandBytes: [UInt8] = [
            0xfe, 0xfe,
            trxAddress, ctrlAddress
        ] +  cmd + (data ?? []) + [0xfd]

        let response = try await interface.command(Data(commandBytes))

        return [UInt8](response ?? Data())
    }

    func onCommand(data: Data) async -> Bool {
        guard data.starts(with: [0xfe, 0xfe]) && data.count >= 5 else {
            debugPrint("Invalid CI-V command")
            return false
        }

        // Check target address (our address or broadcast)
        guard data[2] == self.ctrlAddress || data[2] == 0 else {
            debugPrint("Received CI-V command for other recipient")
            return false
        }

        // Check source address
        guard data[3] == self.trxAddress else {
            debugPrint("Received CI-V command from unknown source")
            return false
        }

        // We can now assume that we are connected
        self.state.status = .connected

        switch data[4] {
        case 0x00:
            if let freq = Self.parseFrequency(from: [UInt8](data[5...9])) {
                self.state.frequency = freq
                await self.stateChannel.send(self.state)
                debugPrint(freq)
            }

        case 0x01:
            if let mode = Self.parseMode(from: UInt8(data[5])) {
                self.state.mode = mode
                await self.stateChannel.send(self.state)
                debugPrint(mode)
            }

        case 0x03:
            debugPrint("received the operating frequency")

        case 0x06:
            debugPrint("set the operating mode")

        default:
            debugPrint("unknown command", data[5])
        }

        // Ackowledge reception
        return true
    }

    public func change(frequency: UInt64) async throws {

    }

    public func change(mode: TransceiverMode) async throws {
        var result: [UInt8]

        switch mode {
        case .ssb(.lsb):
            result = try await command([0x06], data: [0x00, 0x01])
        case .ssb(.usb):
            result = try await command([0x06], data: [0x01, 0x01])
        case .am:
            result = try await command([0x06], data: [0x02, 0x01])
        case .fm:
            result = try await command([0x06], data: [0x05, 0x01])
        case .cw(.usb):
            result = try await command([0x06], data: [0x03, 0x01])
        case .cw(.lsb):
            result = try await command([0x06], data: [0x07, 0x01])
        case .rtty(.usb):
            result = try await command([0x06], data: [0x04, 0x01])
        case .rtty(.lsb):
            result = try await command([0x06], data: [0x08, 0x01])
        }
    }

    private func updateFrequency(freq: UInt64) async throws {
        try await command([0x03], data: Self.frequencyArray(for: freq))
    }

    private static func parseFrequency(from data: [UInt8]) -> UInt64? {
        guard data.count == 5 else { return nil }
        var result: UInt64 = UInt64(data[0] & 0xF) * 1 + UInt64(data[0] >> 4) * 10
        result += UInt64(data[1] & 0xF) * 100 + UInt64(data[1] >> 4) * 1_000
        result += UInt64(data[2] & 0xF) * 10_000 + UInt64(data[2] >> 4) * 100_000
        result += UInt64(data[3] & 0xF) * 1_000_000 + UInt64(data[3] >> 4) * 10_000_000
        result += UInt64(data[4] & 0xF) * 100_000_000 + UInt64(data[4] >> 4) * 1_000_000_000
        return result
    }

    private static func parseMode(from data: UInt8) -> TransceiverMode? {
        switch (data) {
        case 0x00:
            return .ssb(.lsb)
        case 0x01:
            return .ssb(.usb)
        case 0x02:
            return .am
        case 0x03:
            return .cw(.usb)
        case 0x04:
            return .rtty(.usb)
        case 0x05:
            return .fm
        case 0x07:
            return .cw(.lsb)
        case 0x08:
            return .rtty(.lsb)
        default:
            return nil
        }
    }

    private static func frequencyArray(for frequency: UInt64) -> [UInt8] {
        return [
            UInt8(frequency % 1 / 1) | UInt8(frequency % 10 / 10) << 4 ,
            UInt8(frequency % 100 / 100) | UInt8(frequency % 1_000 / 1_000) << 4,
            UInt8(frequency % 10_000 / 10_000) | UInt8(frequency % 100_000 / 100_000) << 4,
            UInt8(frequency % 1_000_000 / 1_000_000) | UInt8(frequency % 10_000_000 / 10_000_000) << 4,
            UInt8(frequency % 100_000_000 / 100_000_000) | UInt8(frequency % 1_000_000_000 / 1_000_000_000) << 4
        ]
    }
}

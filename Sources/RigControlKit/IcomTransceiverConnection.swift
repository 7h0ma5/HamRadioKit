//
//  IcomTransceiver.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation
import AsyncAlgorithms

public class IcomTransceiverConnection: TransceiverControl {
    private var stateChannel: AsyncChannel<TransceiverState>

    private var state = TransceiverState() {
        didSet {
            Task {
                await stateChannel.send(state)
            }
        }
    }

    var interface: any TransceiverInterface
    var commandTask: Task<Void, Error>?

    let ctrlAddress: UInt8 = 0xe0
    let trxAddress: UInt8 = 0xa4

    required public init(interface: any TransceiverInterface, channel: AsyncChannel<TransceiverState>) async {
        self.interface = interface
        self.stateChannel = channel

        self.commandTask = Task {
            for await event in interface.events {
                if Task.isCancelled { break }

                switch event {
                case .statusUpdated(let status):
                    switch status {
                    case .connecting:
                        state.status = .connecting
                    case .connected:
                        state.status = .connected

                        Task {
                            try await updateFrequency()
                            try await updateMode()
                        }

                    case .disconnected:
                        state.status = .disconnected
                    case .error:
                        state.status = .error
                    }
                    await stateChannel.send(state)

                case .dataReceived(let data):
                    await onCommand(data: data)
                }
            }
        }

        self.state.status = .disconnected
    }

    deinit {
        commandTask?.cancel()
    }

    public func connect() async throws {
        self.state.status = .connecting
    }

    func command(_ cmd: [UInt8], data: [UInt8]?) async throws -> [UInt8] {
        let commandBytes: [UInt8] = [
            0xfe, 0xfe,
            trxAddress, ctrlAddress
        ] +  cmd + (data ?? []) + [0xfd]

        let response = try await interface.command(Data(commandBytes))

        return [UInt8](response ?? Data())
    }

    func onCommand(data: Data) async {
        guard data.starts(with: [0xfe, 0xfe]) && data.count >= 5 else {
            debugPrint("Invalid CI-V command")
            return
        }

        // Check target address (our address or broadcast)
        guard data[2] == self.ctrlAddress || data[2] == 0 else {
            debugPrint("Received CI-V command for other recipient")
            return
        }

        // Check source address
        guard data[3] == self.trxAddress else {
            debugPrint("Received CI-V command from unknown source")
            return
        }

        // We can now assume that we are connected
        self.state.status = .connected

        switch data[4] {
        case 0x00:
            if let freq = Self.parseFrequency(from: [UInt8](data[5...9])) {
                self.state.frequency = freq
            }

        case 0x01:
            if let mode = Self.parseMode(from: UInt8(data[5])) {
                self.state.mode = mode
            }

        case 0x03:
            debugPrint("received the operating frequency")

        case 0x06:
            debugPrint("set the operating mode")

        default:
            debugPrint("unknown command", data[5])
        }
    }

    public func change(frequency: UInt64) async throws {
        let result = try await command([0x05], data: Self.frequencyArray(for: frequency))
        guard result.count > 5  && result[4] == 0xfb else { throw TransceiverControlError() }
        self.state.frequency = frequency
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

        guard result.count > 5  && result[4] == 0xfb else { throw TransceiverControlError() }
        self.state.mode = mode
    }

    private func updateFrequency() async throws {
        let result = try await command([0x03], data: [])
        guard result.count > 5 && result[4] == 0x03 else { throw TransceiverControlError() }

        if let freq = Self.parseFrequency(from: [UInt8](result[5...9])) {
            self.state.frequency = freq
        }
    }

    private func updateMode() async throws {
        let result = try await command([0x04], data: [])
        guard result.count > 5 && result[4] == 0x04 else { throw TransceiverControlError() }

        if let mode = Self.parseMode(from: UInt8(result[5])) {
            self.state.mode = mode
        }
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
        switch data {
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
            UInt8(frequency % 10 / 1) | UInt8(frequency % 100 / 10) << 4 ,
            UInt8(frequency % 1_000 / 100) | UInt8(frequency % 10_000 / 1_000) << 4,
            UInt8(frequency % 100_000 / 10_000) | UInt8(frequency % 1_000_000 / 100_000) << 4,
            UInt8(frequency % 10_000_000 / 1_000_000) | UInt8(frequency % 100_000_000 / 10_000_000) << 4,
            UInt8(frequency % 1_000_000_000 / 100_000_000) | UInt8(frequency % 10_000_000_000 / 1_000_000_000) << 4
        ]
    }
}

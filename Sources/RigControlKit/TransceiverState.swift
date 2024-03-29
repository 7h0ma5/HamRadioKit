//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 16.07.22.
//

import Foundation

public enum TransceiverStatus: CaseIterable {
    case connected
    case connecting
    case disconnected
    case error
}

extension TransceiverStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .error: return "Error"
        }
    }
}

public enum TransceiverSideband: Hashable {
    case usb
    case lsb
}

// swiftlint:disable identifier_name
public enum TransceiverMode: Hashable {
    case ssb(TransceiverSideband)
    case cw(TransceiverSideband)
    case am
    case fm
    case rtty(TransceiverSideband)
}
// swiftlint:enable identifier_name

extension TransceiverMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ssb: return "SSB"
        case .cw: return "CW"
        case .am: return "AM"
        case .fm: return "FM"
        case .rtty: return "RTTY"
        }
    }
}

// MARK: -
public struct TransceiverState {
    public var status: TransceiverStatus = .disconnected
    public var frequency: UInt64 = 14_000_000
    public var mode: TransceiverMode = .ssb(.usb)

    public init() { }
}

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

public enum TransceiverMode: CaseIterable {
    case ssb
    case cw
    case am
    case fm
    case rtty
}

public enum TransceiverSideband {
    case usb
    case lsb
}

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
    public var frequency: UInt64 = 0
    public var mode: TransceiverMode = .ssb
    public var sideband: TransceiverSideband = .usb

    public init() { }
}

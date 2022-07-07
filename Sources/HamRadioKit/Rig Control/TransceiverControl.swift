//
//  TransceiverControl.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation

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
    private(set) public var frequency: Frequency = 0
    private(set) public var mode: TransceiverMode = .ssb
    private(set) public var sideband: TransceiverSideband = .usb
}

// MARK: -
public protocol TransceiverControl {
    func connect() async throws
    func change(frequency: Double) async throws
    func change(mode: TransceiverMode, sideband: TransceiverSideband) async throws
}

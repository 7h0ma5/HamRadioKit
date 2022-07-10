//
//  Transceiver.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 28.06.22.
//

import Foundation

public struct Transceiver: Identifiable, Hashable, Codable {
    public enum Interface: String, Hashable, Codable, CaseIterable {
        public static let allCases: [Transceiver.Interface] = [
            .none, .bluetooth, .serial, .network
        ]

        case none
        case bluetooth
        case serial
        case network
    }

    public enum Model: String, CustomStringConvertible, Hashable, Codable, CaseIterable {
        case none
        case ic705
        case ic7300

        public var description: String {
            switch self {
            case .ic705: return "Icom IC-705"
            case .ic7300: return "Icom IC-7300"
            case .none: return "None"
            }
        }
    }

    public let id: UUID
    public var name: String
    public var model: Model
    public var interface: Interface

    public init(id: UUID, name: String, model: Model, interface: Interface) {
        self.id = id
        self.name = name
        self.model = model
        self.interface = interface
    }

    public func connection() -> (any TransceiverControl)? {
        switch self.model {
        case .ic705:
            let interface = BluetoothInterface(connectionId: self.id)
            return IcomTransceiverConnection(interface: interface)
        default:
            return nil
        }
    }
}

extension Transceiver {
    public static var `default`: Transceiver {
        Transceiver(
            id: UUID(),
            name: String(localized: "New Transceiver"),
            model: .none,
            interface: .none
        )
    }
}

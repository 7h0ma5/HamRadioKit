//
//  TransceiverInterface.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 26.06.22.
//

import Foundation
import AsyncAlgorithms

public struct TransceiverInterfaceError: Error {

}

public typealias TransceiverInterfaceEventChannel = AsyncChannel<TransceiverInterfaceEvent>

public enum TransceiverInterfaceStatus {
    case disconnected
    case connecting
    case connected
    case error
}

public enum TransceiverInterfaceEvent {
    case statusUpdated(TransceiverInterfaceStatus)
    case dataReceived(Data)
}

public protocol TransceiverInterface {
    var events: TransceiverInterfaceEventChannel { get }
    func command(_ cmd: Data) async throws -> Data?
}

public protocol TransceiverInterfaceConfig: Hashable, Codable { }

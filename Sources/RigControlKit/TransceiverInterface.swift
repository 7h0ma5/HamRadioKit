//
//  TransceiverInterface.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 26.06.22.
//

import Foundation
import AsyncAlgorithms

public enum TransceiverInterfaceStatus {
    case disconnected
    case connecting
    case connected
    case error
}

public protocol TransceiverInterface {
    var status: TransceiverInterfaceStatus { get }
    var commands: AsyncChannel<Data> { get }

    func connect() async throws
    func command(_ cmd: Data) async throws -> Data?
}

public protocol TransceiverInterfaceConfig: Hashable, Codable { }

//
//  TransceiverInterface.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 26.06.22.
//

import Foundation

public enum TransceiverInterfaceStatus {
    case disconnected
    case connecting
    case connected
    case error
}

public protocol TransceiverInterface {
    var status: TransceiverInterfaceStatus { get }
    var onCommand: ((Data) -> ())? { get set }
    
    func connect() async throws
    func command(_ cmd: Data) async throws -> Data
}

public protocol TransceiverInterfaceConfig: Hashable, Codable { }

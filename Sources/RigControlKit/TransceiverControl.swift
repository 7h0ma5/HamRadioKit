//
//  TransceiverControl.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation
import AsyncAlgorithms

public struct TransceiverControlError: Error {

}

public protocol TransceiverControl {
    func connect() async throws
    func change(frequency: UInt64) async throws
    func change(mode: TransceiverMode) async throws
}

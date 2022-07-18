//
//  TransceiverControl.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation
import AsyncAlgorithms

public protocol TransceiverControl {
    var stateChannel: AsyncChannel<TransceiverState> { get }

    func connect() async throws
    func change(frequency: UInt64) async throws
    func change(mode: TransceiverMode, sideband: TransceiverSideband) async throws
}

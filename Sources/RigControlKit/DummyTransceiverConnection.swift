//
//  DummyTransceiverConnection.swift
//  
//
//  Created by Thomas Gatzweiler on 17.07.22.
//

import Foundation
import AsyncAlgorithms

public class DummyTransceiverConnection: ObservableObject, TransceiverControl {
    public var stateChannel = AsyncChannel(element: TransceiverState.self)
    private var state = TransceiverState()

    public init() {

    }

    public func connect() async throws {
        self.state.status = .connected
        await self.stateChannel.send(self.state)
    }

    public func change(frequency: UInt64) async throws {
        self.state.frequency = frequency
        await self.stateChannel.send(self.state)
    }

    public func change(mode: TransceiverMode) async throws {
        self.state.mode = mode
        await self.stateChannel.send(self.state)
    }
}

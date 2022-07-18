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
        Task {
            while true {
                self.state.frequency += 1000
                await self.stateChannel.send(self.state)
                try await Task.sleep(nanoseconds: 1000000000)
            }
        }
    }

    public func connect() async throws {
        self.state.status = .connected
        await self.stateChannel.send(self.state)
    }

    public func change(frequency: UInt64) async throws {
        self.state.frequency = frequency
        await self.stateChannel.send(self.state)
    }

    public func change(mode: TransceiverMode, sideband: TransceiverSideband) async throws {
        self.state.mode = mode
        self.state.sideband = sideband
        await self.stateChannel.send(self.state)
    }
}

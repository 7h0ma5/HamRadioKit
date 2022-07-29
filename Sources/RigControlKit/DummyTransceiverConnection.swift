//
//  DummyTransceiverConnection.swift
//  
//
//  Created by Thomas Gatzweiler on 17.07.22.
//

import Foundation
import AsyncAlgorithms

public class DummyTransceiverConnection: ObservableObject, TransceiverControl {
    public var stateChannel: AsyncChannel<TransceiverState>
    private var state = TransceiverState()

    required public init(channel: AsyncChannel<TransceiverState>) {
        self.stateChannel = channel
        Task {
            await self.stateChannel.send(state)
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

    public func change(mode: TransceiverMode) async throws {
        self.state.mode = mode
        await self.stateChannel.send(self.state)
    }
}

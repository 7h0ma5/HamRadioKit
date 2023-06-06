//
//  TransceiverConnection.swift
//  
//
//  Created by Thomas Gatzweiler on 17.07.22.
//

import Foundation
import AsyncAlgorithms

public class TransceiverConnection {
    public var stateChannel: AsyncChannel<TransceiverState> = AsyncChannel()

    public var transceiver: Transceiver?
    public var control: any TransceiverControl
    public var state = TransceiverState()

    public init() {
        control = DummyTransceiverConnection(channel: stateChannel)

        Task {
            for await newState in stateChannel {
                self.state = newState
            }
        }
    }

    public func connect(transceiver: Transceiver) async {
        if self.transceiver != nil {
            await self.disconnect()
        }

        self.transceiver = transceiver
        self.control = await transceiver.connection(channel: stateChannel)

        do {
            debugPrint("Trying to connect to transceiver")
            try await self.control.connect()
        }
        catch {
            debugPrint("Failed to connect!")
        }
    }

    public func disconnect() async {
        self.transceiver = nil
        self.control = DummyTransceiverConnection(channel: stateChannel)
    }
}

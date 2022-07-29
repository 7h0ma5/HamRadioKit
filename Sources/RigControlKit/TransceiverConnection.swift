//
//  TransceiverConnection.swift
//  
//
//  Created by Thomas Gatzweiler on 17.07.22.
//

import Foundation
import AsyncAlgorithms

public actor TransceiverConnection {
    public var stateChannel = AsyncChannel(element: TransceiverState.self)

    public var transceiver: Transceiver?
    public var control: any TransceiverControl

    public init() {
        control = DummyTransceiverConnection(channel: stateChannel)
    }

    public func connect(transceiver: Transceiver) async {
        if self.transceiver != nil {
            await self.disconnect()
        }

        self.transceiver = transceiver
        self.control = await transceiver.connection(channel: stateChannel)

        do {
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

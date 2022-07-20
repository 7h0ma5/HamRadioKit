//
//  TransceiverConnection.swift
//  
//
//  Created by Thomas Gatzweiler on 17.07.22.
//

import Foundation

@globalActor
public actor TransceiverConnection {
    public static var shared = TransceiverConnection()

    public var transceiver: Transceiver?
    public var control: any TransceiverControl

    public init() {
        self.control = DummyTransceiverConnection()
    }

    public func connect(transceiver: Transceiver) async {
        self.transceiver = transceiver
        self.control = await transceiver.connection()

        do {
            try await self.control.connect()
        }
        catch {
            debugPrint("Failed to connect!")
        }
    }
}

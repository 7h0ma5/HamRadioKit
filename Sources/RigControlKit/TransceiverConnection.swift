//
//  TransceiverConnection.swift
//  
//
//  Created by Thomas Gatzweiler on 17.07.22.
//

import Foundation

public class TransceiverConnection {
    public var control: any TransceiverControl

    public init() {
        self.control = DummyTransceiverConnection()
    }

    public func connect(control: any TransceiverControl) async {
        self.control = control
    }
}

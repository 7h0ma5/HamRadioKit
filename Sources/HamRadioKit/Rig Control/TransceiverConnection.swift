//
//  TransceiverConnection.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation

public class TransceiverConnection: ObservableObject {
    public static let shared = TransceiverConnection()
   
    @Published public var state = TransceiverState()
    public var control: (any TransceiverControl)?
   
    public init() {

    }

    public func connect() async throws {
        if let control = control {
            try await control.connect()
            /*
            try await control.change(mode: .ssb, sideband: .usb)

            while true {
                DispatchQueue.main.async {
                    self.state.frequency += 1_000_000
                }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                try await control.change(mode: .cw, sideband: .lsb)
            }*/
        }
    }
}

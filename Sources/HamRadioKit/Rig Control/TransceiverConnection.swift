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
    var control: (any TransceiverControl)?
   
    public init() {
        let decoder = JSONDecoder()
        
        guard let list = UserDefaults.standard.dictionary(forKey: "qlog.transceivers") as? [String:Data] else {
            return
        }
        
        var transceivers: [UUID:Transceiver] = [:]
        
        for (key, item) in list {
            if let key = UUID(uuidString: key), let trx = try? decoder.decode(Transceiver.self, from: item) {
                transceivers[key] = trx
            }
        }
        
        guard let trx = transceivers.first?.value else { return }
    
        control = IcomTransceiverConnection(interface: BluetoothInterface(connectionId: trx.id))
    }
    
    public func connect() async throws {
        if let control = control {
            try await control.interface.connect()
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

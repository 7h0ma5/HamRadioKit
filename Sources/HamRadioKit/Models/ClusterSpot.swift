//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 09.07.22.
//

import Foundation

public struct ClusterSpot: Codable, Equatable {
    public let id: UUID
    public let callsign: String
    public let spotter: String
    public let frequency: Frequency
    public let timestamp: Date
    public let dxccId: DXCC?
    public let comment: String?
    public let gridsquare: Locator?

    public init(id: UUID, callsign: String, spotter: String,
                frequency: Frequency, timestamp: Date, dxccId: DXCC?,
                comment: String?, gridsquare: Locator?) {
        self.id = id
        self.callsign = callsign
        self.spotter = spotter
        self.frequency = frequency
        self.timestamp = timestamp
        self.dxccId = dxccId
        self.comment = comment
        self.gridsquare = gridsquare
    }
}

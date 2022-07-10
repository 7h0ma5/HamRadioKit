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
    public let comment: String?
    public let gridsquare: Locator?

    public init(id: UUID, callsign: String, spotter: String, frequency: Frequency, timestamp: Date, comment: String?, gridsquare: Locator?) {
        self.id = id
        self.callsign = callsign
        self.spotter = spotter
        self.frequency = frequency
        self.timestamp = timestamp
        self.comment = comment
        self.gridsquare = gridsquare
    }
}

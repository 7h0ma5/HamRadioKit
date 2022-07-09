//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 09.07.22.
//

import Foundation

struct ClusterSpot: Codable {
    let callsign: String
    let spotter: String
    let dxccId: DXCC?
    let frequency: Frequency
    let time: Date
    let comment: String
    let gridsquare: Locator?
}

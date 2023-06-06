//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 06.07.22.
//

import Foundation

public struct CallbookEntry {
    public let callsign: String
    public let name: String?
    public let qth: String?
    public let gridsquare: Locator?
    public let country: String?
    public let dxccId: DXCC?
    public let coordinates: (lat: Double, lon: Double)?
}

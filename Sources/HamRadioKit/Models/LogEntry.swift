//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 04.07.22.
//

import Foundation

public enum QSLReceivedStatus: String, Codable, CaseIterable {
    case yes = "Y"
    case no = "N"
    case requested = "R"
    case ignore = "I"
}

public enum QSLSentStatus: String, Codable, CaseIterable {
    case yes = "Y"
    case no = "N"
    case requested = "R"
    case queued = "Q"
    case ignore = "I"
}

public struct LogEntry: Codable, Identifiable {
    public var id: UUID = UUID()
    public var logbookId: UUID?
    public var callsign: String = ""
    public var rstSent: String?
    public var rstRcvd: String?
    public var startTime: Date = Date()
    public var endTime: Date?
    public var name: String?
    public var qth: String?
    public var gridsquare: Locator?
    public var freq: Frequency?
    public var band: Band?
    public var mode: Mode? {
        didSet {
            dxccMode = mode?.dxccMode
        }
    }
    public var submode: String?
    public var dxcc: UInt64?
    private(set) var dxccMode: DXCCMode?
    public var cqz: UInt64?
    public var ituz: UInt64?
    public var cont: String?
    public var country: String?
    public var pfx: String?
    public var state: String?
    public var cnty: String?
    public var lat: Double?
    public var lon: Double?
    public var iota: String?
    public var sota: String?
    public var qslRcvd: QSLReceivedStatus = .no
    public var qslRdate: Date?
    public var qslSent: QSLSentStatus = .no
    public var qslSdate: Date?
    public var qslVia: String?
    public var lotwQslRcvd: QSLReceivedStatus = .no
    public var lotwQslRdate: Date?
    public var lotwQslSent: QSLSentStatus = .no
    public var lotwQslSdate: Date?
    public var txPwr: Double?
    public var comment: String?
    public var notes: String?
    public var myAntenna: String?
    public var myRig: String?
    public var myGridsquare: Locator?
    public var myDxcc: UInt64?
    public var myLat: Double?
    public var myLon: Double?
    public var myIota: String?
    public var mySota: String?
    public var stationCallsign: String?
    public var stationOperator: String?
    public var contestId: String?
    public var serialSent: String?
    public var serialRcvd: String?
    
    public enum CodingKeys: CodingKey {
        case id, logbookId, callsign, startTime, gridsquare, dxcc, dxccMode, band, mode
    }
    
    public init() {
        
    }
}

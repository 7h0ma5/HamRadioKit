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
    private(set) public var dxccMode: DXCCMode?
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

    public enum CodingKeys: String, CodingKey {
        case id
        case logbookId
        case callsign
        case rstSent
        case rstRcvd
        case startTime
        case endTime
        case name
        case qth
        case gridsquare
        case freq
        case band
        case mode
        case submode
        case dxcc
        case dxccMode
        case cqz
        case ituz
        case cont
        case country
        case pfx
        case state
        case cnty
        case lat
        case lon
        case iota
        case sota
        case qslRcvd
        case qslRdate
        case qslSent
        case qslSdate
        case qslVia
        case lotwQslRcvd
        case lotwQslRdate
        case lotwQslSent
        case lotwQslSdate
        case txPwr
        case comment
        case notes
        case myAntenna
        case myRig
        case myGridsquare
        case myDxcc
        case myLat
        case myLon
        case myIota
        case mySota
        case stationCallsign
        case stationOperator
        case contestId
        case serialSent
        case serialRcvd
    }

    public init() {}
}

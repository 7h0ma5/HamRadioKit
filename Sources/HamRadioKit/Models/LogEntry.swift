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

public struct LogEntry: Codable, Identifiable, Hashable, Equatable {
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
    /// TX Frequency of the QSO in Hz
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

extension LogEntry {
    private static func randomSuffix() -> String {
        let length = Int.random(in: 2...3)
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    static let names: [String] = [
        "Maria", "Jose", "Mohammed", "Anna", "John", "Ali",
        "Robert", "Jean",  "Elena", "Min", "Paul", "Sarah"
    ]

    // swiftlint:disable:next large_tuple
    static let countries: [(prefix: String, qth: String, dxccId: DXCC, ituz: UInt64, cqz: UInt64)] = [
        ("VU", "New Delhi", 324, 41, 22),
        ("LA", "Oslo", 266, 18, 14),
        ("M", "London", 223, 27, 14),
        ("JA", "Tokyo", 339, 45, 25),
        ("F", "Paris", 227, 27, 14),
        ("DL", "Berlin", 230, 28, 14),
        ("EA", "Madrid", 281, 37, 14),
        ("K", "New York", 291, 6, 3),
        ("ON", "Brussels", 209, 27, 14),
        ("TF", "Reykjavik", 242, 17, 40),
        ("I", "Rome", 248, 28, 15),
        ("UR", "Kyiv", 288, 29, 16),
        ("VK", "Sydney", 150, 60, 29),
        ("ZL", "Wellington", 170, 60, 32),
        ("ZS", "Cape Town", 462, 57, 38)
    ]

    static let bands: [Band] = [
        ._160m,
        ._80m,
        ._40m,
        ._20m,
        ._15m,
        ._10m,
        ._2m
    ]

    static let modes: [Mode] = [
        .cw,
        .ssb,
        .ft8,
        .rtty
    ]

    public static func random() -> LogEntry? {
        guard let country = countries.randomElement() else { return nil }

        var entry = LogEntry()
        entry.startTime = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate.rounded())
        entry.endTime = entry.startTime.addingTimeInterval(Double.random(in: 5...300).rounded())
        entry.callsign = "\(country.prefix)\(Int.random(in: 0...9))\(randomSuffix())"
        entry.name = names.randomElement()
        entry.qth = country.qth
        entry.mode = modes.randomElement()
        entry.band = bands.randomElement()
        entry.rstRcvd = entry.mode?.defaultReport
        entry.rstSent = entry.mode?.defaultReport
        entry.freq = entry.band?.freqRange.randomElement()!
        entry.dxcc = country.dxccId
        entry.ituz = country.ituz
        entry.cqz = country.cqz
        entry.country = country.dxccId.name
        entry.pfx = country.prefix
        entry.qslRcvd = QSLReceivedStatus.allCases.randomElement() ?? .no
        entry.qslSent = QSLSentStatus.allCases.randomElement() ?? .no

        return entry
    }
}

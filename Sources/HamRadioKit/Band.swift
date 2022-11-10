//
//  Bands.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 15.05.22.
//

import Foundation

public typealias FrequencyRange = ClosedRange<Frequency>

public enum Band: String, CaseIterable, Codable, CustomStringConvertible {
    // swiftlint:disable identifier_name
    case _2190m = "2190m"
    case _630m = "630m"
    case _560m = "560m"
    case _160m = "160m"
    case _80m = "80m"
    case _60m = "60m"
    case _40m = "40m"
    case _30m = "30m"
    case _20m = "20m"
    case _17m = "17m"
    case _15m = "15m"
    case _12m = "12m"
    case _10m = "10m"
    case _6m = "6m"
    case _4m = "4m"
    case _2m = "2m"
    case _1m25 = "1.25m"
    case _70cm = "70cm"
    case _33cm = "33cm"
    case _23cm = "23cm"
    case _13cm = "13cm"
    case _9cm = "9cm"
    case _6cm = "6cm"
    case _3cm = "3cm"
    case _1cm25 = "1.25cm"
    case _6mm = "6mm"
    case _4mm = "4mm"
    case _2mm5 = "2.5mm"
    case _2mm = "2mm"
    case _1mm = "1mm"
    // swiftlint:enable identifier_name

    public var description: String {
        return self.name
    }

    public var name: String {
        return self.rawValue
    }

    static let tree = IntervalTree.init(buildWith: Self.allCases, rangeKey: \.freqRange)

    public static func find(byName name: String) -> Band? {
        Band(rawValue: name)
    }

    public static func find(forFreq freq: Frequency) -> Band? {
        return tree.search(point: freq).first
    }

    public static func find(inRange range: FrequencyRange) -> [Band] {
        return tree.search(range: range)
    }

    public var freqRange: FrequencyRange {
        switch self {
        case ._2190m: return 136_000...137_000
        case ._630m: return 472_000...479_000
        case ._560m: return 501_000...504_000
        case ._160m: return 1_800_000...2_000_000
        case ._80m: return 3_500_000...4_000_000
        case ._60m: return 5_102_000...5_406_500
        case ._40m: return 7_000_000...7_300_000
        case ._30m: return 10_100_000...10_150_000
        case ._20m: return 14_000_000...14_350_000
        case ._17m: return 18_068_000...18_168_000
        case ._15m: return 21_000_000...21_450_000
        case ._12m: return 24_890_000...24_990_000
        case ._10m: return 28_000_000...29_700_000
        case ._6m: return 50_000_000...52_000_000
        case ._4m: return 70_000_000...71_000_000
        case ._2m: return 144_000_000...148_000_000
        case ._1m25: return 222_000_000...225_000_000
        case ._70cm: return 420_000_000...450_000_000
        case ._33cm: return 902_000_000...928_000_000
        case ._23cm: return 1240_000_000...1300_000_000
        case ._13cm: return 2300_000_000...2450_000_000
        case ._9cm: return 3300_000_000...3500_000_000
        case ._6cm: return 5650_000_000...5925_000_000
        case ._3cm: return 10_000_000_000...10500_000_000
        case ._1cm25: return 24_000_000_000...24_250_000_000
        case ._6mm: return 47_000_000_000...47_200_000_000
        case ._4mm: return 75_500_000_000...81_000_000_000
        case ._2mm5: return 119_980_000_000...120_020_000_000
        case ._2mm: return 142_000_000_000...149_000_000_000
        case ._1mm: return 241_000_000_000...250_000_000_000
        }
    }
}

protocol Bandplan {

}

public struct BandplanFrequency {
    public let band: Band
    public let freq: Frequency
    public let freqType: FrequencyType

    public enum FrequencyType {
        case cwQrs
        case cwQrp
        case ssbQrp
        case fmCall
        case cwCall
        case ssbCall
        case sstv
        case emergency
    }

    init(_ band: Band, freq: Frequency, type: FrequencyType) {
        self.band = band
        self.freq = freq
        self.freqType = type
    }
}

public struct BandplanRange {
    public let band: Band
    public let range: FrequencyRange
    public let rangeType: RangeType

    public enum RangeType {
        case dxccMode(DXCCMode)
        case contestPreferred
        case beaconOnly
        case dxPreferred
    }

    init(_ band: Band, range: FrequencyRange, type: RangeType) {
        self.band = band
        self.range = range
        self.rangeType = type
    }
}

public struct Region1Bandplan: Bandplan {
    var intervalTree: IntervalTree<Frequency, BandplanRange>
    var rangeTree: RangeTree<Frequency, BandplanFrequency>

    public static let shared = Region1Bandplan()

    init() {
        self.intervalTree = .init(buildWith: Self.ranges, rangeKey: \.range)
        self.rangeTree = .init(buildWith: Self.frequencies, key: \.freq)
    }

    public func searchRanges(in range: FrequencyRange) -> [BandplanRange] {
        self.intervalTree.search(range: range)
    }

    public func searchFrequencies(in range: FrequencyRange) -> [BandplanFrequency] {
        self.rangeTree.search(range: range)
    }

    public func dxccMode(forFreq freq: Frequency) -> DXCCMode? {
        self.intervalTree.search(point: freq)
            .map {
                switch $0.rangeType {
                case .dxccMode(let mode):
                    return mode
                default:
                    return nil
                }
            }
            .compactMap { $0 }
            .first
    }

    static let ranges: [BandplanRange] = [
        .init(._2190m, range: 135_700...135_800, type: .dxccMode(.cw)),

        .init(._630m, range: 472_000...479_000, type: .dxccMode(.cw)),
        .init(._630m, range: 475_000...479_000, type: .dxccMode(.digital)),

        .init(._160m, range: 1_810_000...1_838_000, type: .dxccMode(.cw)),
        .init(._160m, range: 1_838_000...1_843_000, type: .dxccMode(.digital)),
        .init(._160m, range: 1_843_000...2_000_000, type: .dxccMode(.phone)),

        .init(._80m, range: 3_500_000...3_570_000, type: .dxccMode(.cw)),
        .init(._80m, range: 3_510_000...3_560_000, type: .contestPreferred),
        .init(._80m, range: 3_570_000...3_600_000, type: .dxccMode(.digital)),
        .init(._80m, range: 3_600_000...3_800_000, type: .dxccMode(.phone)),
        .init(._80m, range: 3_600_000...3_650_000, type: .contestPreferred),
        .init(._80m, range: 3_700_000...3_800_000, type: .contestPreferred),
        .init(._80m, range: 3_775_000...3_800_000, type: .dxPreferred),

        .init(._60m, range: 5_351_500...5_354_000, type: .dxccMode(.cw)),
        .init(._60m, range: 5_354_000...5_366_500, type: .dxccMode(.digital)),
        .init(._60m, range: 5_354_000...5_366_000, type: .dxccMode(.phone)),

        .init(._40m, range: 7_000_000...7_040_000, type: .dxccMode(.cw)),
        .init(._40m, range: 7_040_000...7_050_000, type: .dxccMode(.digital)),
        .init(._40m, range: 7_050_000...7_200_000, type: .dxccMode(.phone)),
        .init(._40m, range: 7_060_000...7_100_000, type: .contestPreferred),
        .init(._40m, range: 7_130_000...7_200_000, type: .contestPreferred),
        .init(._40m, range: 7_175_000...7_200_000, type: .dxPreferred),

        .init(._30m, range: 10_100_000...10_130_000, type: .dxccMode(.cw)),
        .init(._30m, range: 10_130_000...10_150_000, type: .dxccMode(.digital)),

        .init(._20m, range: 14_000_000...14_070_000, type: .dxccMode(.cw)),
        .init(._20m, range: 14_000_000...14_060_000, type: .contestPreferred),
        .init(._20m, range: 14_070_000...14_099_000, type: .dxccMode(.digital)),
        .init(._20m, range: 14_099_000...14_101_000, type: .beaconOnly),
        .init(._20m, range: 14_101_000...14_350_000, type: .dxccMode(.phone)),
        .init(._20m, range: 14_125_000...14_300_000, type: .contestPreferred),

        .init(._17m, range: 18_068_000...18_095_000, type: .dxccMode(.cw)),
        .init(._17m, range: 18_095_000...18_109_000, type: .dxccMode(.digital)),
        .init(._17m, range: 14_109_000...14_111_000, type: .beaconOnly),
        .init(._17m, range: 18_111_000...18_168_000, type: .dxccMode(.phone)),

        .init(._15m, range: 21_000_000...21_070_000, type: .dxccMode(.cw)),
        .init(._15m, range: 21_070_000...21_149_000, type: .dxccMode(.digital)),
        .init(._15m, range: 21_149_000...21_151_000, type: .beaconOnly),
        .init(._15m, range: 21_151_000...21_450_000, type: .dxccMode(.phone)),

        .init(._12m, range: 24_890_000...24_915_000, type: .dxccMode(.cw)),
        .init(._12m, range: 24_915_000...24_929_000, type: .dxccMode(.digital)),
        .init(._12m, range: 24_929_000...24_931_000, type: .beaconOnly),
        .init(._12m, range: 24_931_000...24_940_000, type: .dxccMode(.digital)),
        .init(._12m, range: 24_940_000...24_990_000, type: .dxccMode(.digital)),

        .init(._10m, range: 28_000_000...28_070_000, type: .dxccMode(.cw)),
        .init(._10m, range: 28_070_000...28_190_000, type: .dxccMode(.digital)),
        .init(._10m, range: 28_190_000...28_225_000, type: .beaconOnly),
        .init(._10m, range: 28_225_000...28_320_000, type: .dxccMode(.digital)),
        .init(._10m, range: 28_320_000...29_000_000, type: .dxccMode(.phone)),

        .init(._6m, range: 50_000_000...50_030_000, type: .beaconOnly),
        .init(._6m, range: 50_030_000...50_100_000, type: .dxccMode(.cw)),
        .init(._6m, range: 50_100_000...50_300_000, type: .dxccMode(.phone)),
        .init(._6m, range: 50_100_000...50_130_000, type: .dxPreferred),
        .init(._6m, range: 50_300_000...50_400_000, type: .dxccMode(.digital)),
        .init(._6m, range: 50_400_000...50_500_000, type: .beaconOnly),

        .init(._4m, range: 70_000_000...70_100_000, type: .beaconOnly),

        .init(._2m, range: 144_025_000...144_100_000, type: .dxccMode(.cw)),
        .init(._2m, range: 144_100_000...144_150_000, type: .dxccMode(.digital)),
        .init(._2m, range: 144_150_000...144_400_000, type: .dxccMode(.phone)),
        .init(._2m, range: 144_400_000...144_490_000, type: .beaconOnly)
    ]

    static let frequencies: [BandplanFrequency] = [
        .init(._160m, freq: 1_836_000, type: .cwQrp),

        .init(._80m, freq: 3_555_000, type: .cwQrs),
        .init(._80m, freq: 3_560_000, type: .cwQrp),
        .init(._80m, freq: 3_735_000, type: .sstv),
        .init(._80m, freq: 3_760_000, type: .emergency),

        .init(._40m, freq: 7_030_000, type: .cwQrp),
        .init(._40m, freq: 7_035_000, type: .cwQrs),
        .init(._40m, freq: 7_090_000, type: .ssbQrp),
        .init(._40m, freq: 7_110_000, type: .emergency),
        .init(._40m, freq: 7_165_000, type: .sstv),

        .init(._30m, freq: 10_116_000, type: .cwQrp),

        .init(._20m, freq: 14_060_000, type: .cwQrp),
        .init(._20m, freq: 14_055_000, type: .cwQrs),
        .init(._20m, freq: 14_230_000, type: .sstv),
        .init(._20m, freq: 14_300_000, type: .emergency),

        .init(._17m, freq: 18_086_000, type: .cwQrp),
        .init(._17m, freq: 18_130_000, type: .ssbQrp),
        .init(._17m, freq: 18_160_000, type: .emergency),

        .init(._15m, freq: 21_055_000, type: .cwQrs),
        .init(._15m, freq: 21_060_000, type: .cwQrp),
        .init(._15m, freq: 21_285_000, type: .ssbQrp),
        .init(._15m, freq: 21_360_000, type: .emergency),

        .init(._12m, freq: 24_906_000, type: .cwQrp),
        .init(._12m, freq: 24_950_000, type: .ssbQrp),

        .init(._10m, freq: 28_055_000, type: .cwQrs),
        .init(._10m, freq: 28_060_000, type: .cwQrp),
        .init(._10m, freq: 28_360_000, type: .ssbQrp),

        .init(._2m, freq: 144_050_000, type: .cwCall),
        .init(._2m, freq: 144_300_000, type: .ssbCall),
        .init(._2m, freq: 145_500_000, type: .fmCall)
    ]
}

#if !os(Linux)
@available(macOS 12.0, *)
extension BandplanRange.RangeType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dxccMode(let mode): return mode.description
        case .contestPreferred: return String(localized: "Contest Preferred")
        case .beaconOnly: return String(localized: "Beacon Only")
        case .dxPreferred: return String(localized: "DX Preferred")
        }
    }
}

@available(macOS 12.0, *)
extension BandplanFrequency.FrequencyType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cwQrs: return String(localized: "CW QRS")
        case .cwQrp: return String(localized: "CW QRP")
        case .ssbQrp: return String(localized: "SSB QRP")
        case .fmCall: return String(localized: "FM Call")
        case .ssbCall: return String(localized: "SSB Call")
        case .cwCall: return String(localized: "CW Call")
        case .sstv: return String(localized: "SSTV")
        case .emergency: return String(localized: "Emergency Frequency")
        }
    }
}
#endif

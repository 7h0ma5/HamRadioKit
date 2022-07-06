//
//  Bands.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 15.05.22.
//

import Foundation

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
    
    public static func find(byName name: String) -> Band? {
        Band(rawValue: name)
    }
    
    public static func find(forFreq freq: Frequency) -> Band? {
        return Band.allCases.first(where: { $0.freqRange.contains(freq) })
    }
    
    public var freqRange: ClosedRange<Frequency> {
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

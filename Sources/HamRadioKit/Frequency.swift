//
//  Frequency.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.06.22.
//

import Foundation

public typealias Frequency = UInt64

public extension Frequency {
    #if !os(Linux)
    static let format = Measurement<UnitFrequency>.FormatStyle
        .measurement(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle:
                FloatingPointFormatStyle()
                    .precision(.fractionLength(3))
        )
    #endif
 
    init?<S>(fromMegaHertz data: S) where S: StringProtocol {
        if let doubleValue = Double(data) {
            self = UInt64((doubleValue * 1e6).rounded())
        }
        else {
            return nil
        }
    }

    var band: Band? {
        Band.find(forFreq: self)
    }

    #if !os(Linux)
    var measurement: Measurement<UnitFrequency> {
        if self < 1_000_000 {
            return Measurement<UnitFrequency>(value: Double(self) / 1e3, unit: .kilohertz)
        }
        else if self < 1_000_000_000 {
            return Measurement<UnitFrequency>(value: Double(self) / 1e6, unit: .megahertz)
        }
        else {
            return Measurement<UnitFrequency>(value: Double(self) / 1e9, unit: .gigahertz)
        }
    }
    #endif
}

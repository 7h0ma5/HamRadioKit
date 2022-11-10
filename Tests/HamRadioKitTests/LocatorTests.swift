//
//  LocatorTests.swift
//  HamRadioKit
//
//  Created by Thomas Gatzweiler on 04.07.22.
//

import XCTest
@testable import HamRadioKit

class LocatorTests: XCTestCase {
    func testCoordinateCalculation() throws {
        try [
            ("AA", -90.0, -180.0),
            ("AR", 80.0, -180.0),
            ("RR", 80.0, 160.0),
            ("RA", -90, 160.0),
            ("AA11", -89.0, -178.0),
            ("RR99", 89.0, 178.0),
            ("AA00AA", -90.0, -180.0),
            ("RR99XX", 90 - (2.5 / 60.0), 180 - (5.0 / 60.0))
        ].forEach {
            try testCoordinateCalculation(locator: $0, lat: $1, lon: $2)
        }
    }
    
    func testCoordinateCalculation(locator: Locator, lat: Double, lon: Double) throws {
        XCTAssertTrue(locator.isValid)
        let coordinate = locator.coordinate!
    
        XCTAssertNotNil(coordinate)
        XCTAssertEqual(coordinate.latitude, lat, accuracy: 1e-10)
        XCTAssertEqual(coordinate.longitude, lon, accuracy: 1e-10)
    }
    
    func testInvalid() throws {
        XCTAssertFalse(Locator("SC23").isValid)
        XCTAssertFalse(Locator("JO12A").isValid)
        XCTAssertFalse(Locator("RS00AB").isValid)
        XCTAssertFalse(Locator("TS87AB").isValid)
        XCTAssertFalse(Locator("AABBCC").isValid)
        XCTAssertFalse(Locator("00DD11").isValid)
        XCTAssertFalse(Locator("11ABCD").isValid)
        XCTAssertFalse(Locator("MO96QY").isValid)
    }

    func testLocatorGeneration() throws {
        XCTAssertEqual(Locator(latitude: 50.7747536, longitude: 6.0839191), "JO30BS")
        XCTAssertEqual(Locator(latitude: 65.0677, longitude: -149.8535), "BP55BB")
        XCTAssertEqual(Locator(latitude: -27.1161, longitude: -109.3591), "DG52HV")
        XCTAssertEqual(Locator(latitude: -48.0249, longitude: 166.6022), "RE31HX")
        XCTAssertEqual(Locator(latitude: -90.0, longitude: -180.0), "AA00AA")
        XCTAssertEqual(Locator(latitude: 89.99999, longitude: -180.0), "AR09AX")
        XCTAssertEqual(Locator(latitude: -90.0, longitude: 179.99999), "RA90XA")
        XCTAssertEqual(Locator(latitude: 89.99999, longitude: 179.99999), "RR99XX")
    }

    func testPerformance() throws {
        self.measure {
            let locator = Locator("JO30BS")
            XCTAssertTrue(locator.isValid)
            XCTAssertNotNil(locator.center)
        }
    }

}

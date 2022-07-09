//
//  AdifTests.swift
//  
//
//  Created by Thomas Gatzweiler on 08.07.22.
//

import XCTest
@testable import HamRadioKit

class AdifTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWriter() throws {
        let exportedEntry = try XCTUnwrap(LogEntry.random())

        XCTAssertGreaterThan(exportedEntry.callsign.count, 2)

        let writer = AdifWriter(withHeader: false)
        writer.write(entry: exportedEntry)

        let reader = AdifReader(data: writer.data[...])
        let importedEntry = try XCTUnwrap(reader.readEntry())

        XCTAssertEqual(importedEntry, exportedEntry)
    }

    func testPerformance() throws {
        let entries = try (0...100).map { _ in
            try XCTUnwrap(LogEntry.random())
        }

        self.measure {
            for exportedEntry in entries {
                let writer = AdifWriter(withHeader: false)
                writer.write(entry: exportedEntry)
                let reader = AdifReader(data: writer.data[...])
                let importedEntry = reader.readEntry()
                XCTAssertNotNil(importedEntry)
            }
        }
    }

}

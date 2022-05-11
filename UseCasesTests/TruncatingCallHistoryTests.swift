//
//  TruncatingCallHistoryTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import UseCases
import UseCasesTestDoubles
import XCTest

final class TruncatingCallHistoryTests: XCTestCase {
    func testCanAddRecords() {
        let sut = TruncatingCallHistory()
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)

        sut.add(record1)
        sut.add(record2)

        XCTAssertEqual(sut.allRecords, [record1, record2])
    }

    func testCanRemoveIndividualRecords() {
        let sut = TruncatingCallHistory()
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        sut.add(record1)
        sut.add(record2)

        sut.remove(record1)

        XCTAssertEqual(sut.allRecords, [record2])
    }

    func testCanRemoveAllRecords() {
        let sut = TruncatingCallHistory()
        let factory = CallHistoryRecordTestFactory()
        sut.add(factory.makeRecord(number: 1))
        sut.add(factory.makeRecord(number: 2))

        sut.removeAll()

        XCTAssertEqual(sut.allRecords, [])
    }

    func testKeepsLimitedNumberOfRecords() {
        let limit = 5
        let sut = TruncatingCallHistory(limit: limit)
        let factory = CallHistoryRecordTestFactory()

        for n in 1...10 {
            sut.add(factory.makeRecord(number: n))
        }

        XCTAssertEqual(sut.allRecords.count, limit)
    }

    func testDropsRecordsFromTheBeginningWhenTruncating() {
        let sut = TruncatingCallHistory(limit: 2)
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let record3 = factory.makeRecord(number: 3)
        let record4 = factory.makeRecord(number: 4)

        sut.add(record1)
        sut.add(record2)
        sut.add(record3)
        sut.add(record4)

        XCTAssertEqual(sut.allRecords, [record3, record4])
    }
}

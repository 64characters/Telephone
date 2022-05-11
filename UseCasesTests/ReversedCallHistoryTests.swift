//
//  ReversedCallHistoryTests.swift
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

final class ReversedCallHistoryTests: XCTestCase {
    func testReturnsAllRecordsReversed() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let record3 = factory.makeRecord(number: 3)
        let sut = ReversedCallHistory(origin: TruncatingCallHistory())
        sut.add(record1)
        sut.add(record2)
        sut.add(record3)

        XCTAssertEqual(sut.allRecords, [record3, record2, record1])
    }

    func testAddsRecordsToOriginOnAdd() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let origin = TruncatingCallHistory()
        let sut = ReversedCallHistory(origin: origin)

        sut.add(record1)
        sut.add(record2)

        XCTAssertEqual(origin.allRecords, [record1, record2])
    }

    func testRemovesRecordsFromOriginOnRemove() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let origin = TruncatingCallHistory()
        let sut = ReversedCallHistory(origin: origin)
        sut.add(record1)
        sut.add(record2)

        sut.remove(record1)

        XCTAssertEqual(origin.allRecords, [record2])
    }

    func testRemovesAllRecordsFromOriginOnRemoveAll() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let origin = TruncatingCallHistory()
        let sut = ReversedCallHistory(origin: origin)
        sut.add(record1)
        sut.add(record2)

        sut.removeAll()

        XCTAssertTrue(origin.allRecords.isEmpty)
    }

    func testUpdatesTargetOnOriginOnUpdateTarget() {
        let sut = ReversedCallHistory(origin: NotifyingCallHistory(origin: TruncatingCallHistory()))
        let target = CallHistoryEventTargetSpy()

        sut.updateTarget(target)
        sut.add(CallHistoryRecordTestFactory().makeRecord(number: 1))

        XCTAssertTrue(target.didCallDidUpdate)
    }
}

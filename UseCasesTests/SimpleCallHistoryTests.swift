//
//  SimpleCallHistoryTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

final class SimpleCallHistoryTests: XCTestCase {
    func testCanAddRecords() {
        let sut = SimpleCallHistory()
        let record1 = makeRecord1()
        let record2 = makeRecord2()

        sut.add(record1)
        sut.add(record2)

        XCTAssertEqual(sut.allRecords, [record1, record2])
    }

    func testCanRemoveIndividualRecords() {
        let sut = SimpleCallHistory()
        let record1 = makeRecord1()
        let record2 = makeRecord2()
        sut.add(record1)
        sut.add(record2)

        sut.remove(at: 0)

        XCTAssertEqual(sut.allRecords, [record2])
    }

    func testCanRemoveAllRecords() {
        let sut = SimpleCallHistory()
        let record1 = makeRecord1()
        let record2 = makeRecord2()
        sut.add(record1)
        sut.add(record2)

        sut.removeAll()

        XCTAssertEqual(sut.allRecords, [])
    }
}

private func makeRecord1() -> CallHistoryRecord {
    return CallHistoryRecordTestFactory().makeRecord(number: 1)
}

private func makeRecord2() -> CallHistoryRecord {
    return CallHistoryRecordTestFactory().makeRecord(number: 2)
}

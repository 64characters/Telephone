//
//  CallHistoryRecordAddUseCaseTests.swift
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

final class CallHistoryRecordAddUseCaseTests: XCTestCase {
    func testAddsRecordToHistory() {
        let history = TruncatingCallHistory()
        let record = CallHistoryRecordTestFactory().makeRecord(number: 1)
        let sut = CallHistoryRecordAddUseCase(history: history, record: record, domain: "different")

        sut.execute()

        XCTAssertEqual(history.allRecords, [record])
    }

    func testAddsCopyOfRecordWithEmptyHostWhenHostMatchesDomain() {
        let history = TruncatingCallHistory()
        let record = CallHistoryRecordTestFactory().makeRecord(number: 1)
        let sut = CallHistoryRecordAddUseCase(history: history, record: record, domain: record.host)
        let expected = CallHistoryRecord(user: record.user, host: "", date: record.date, isIncoming: record.isIncoming, isMissed: record.isMissed)

        sut.execute()

        XCTAssertEqual(history.allRecords, [expected])
    }

    func testAddsCopyOfRecordWithEmptyHostWhenUserIsATelephoneNumberLongerThanFourCharacters() {
        let history = TruncatingCallHistory()
        let record = CallHistoryRecord(user: "12345", host: "any-host", date: Date(), isIncoming: false, isMissed: false)
        let sut = CallHistoryRecordAddUseCase(history: history, record: record, domain: "different")
        let expected = CallHistoryRecord(user: record.user, host: "", date: record.date, isIncoming: record.isIncoming, isMissed: record.isMissed)

        sut.execute()

        XCTAssertEqual(history.allRecords, [expected])
    }

    func testAddsOriginalRecordWhenUserIsATelephoneNumberWithLengthEqualToFourCharacters() {
        let history = TruncatingCallHistory()
        let record = CallHistoryRecord(user: "1234", host: "any-host", date: Date(), isIncoming: false, isMissed: false)
        let sut = CallHistoryRecordAddUseCase(history: history, record: record, domain: "different")

        sut.execute()

        XCTAssertEqual(history.allRecords, [record])
    }

    func testAddsOriginalRecordWhenUserIsATelephoneNumberShorterThanFourCharacters() {
        let history = TruncatingCallHistory()
        let record = CallHistoryRecord(user: "123", host: "any-host", date: Date(), isIncoming: false, isMissed: false)
        let sut = CallHistoryRecordAddUseCase(history: history, record: record, domain: "different")

        sut.execute()

        XCTAssertEqual(history.allRecords, [record])
    }
}

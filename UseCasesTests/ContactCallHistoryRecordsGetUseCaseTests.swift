//
//  ContactCallHistoryRecordsGetUseCaseTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

import XCTest
import UseCases
import UseCasesTestDoubles

final class ContactCallHistoryRecordsGetUseCaseTests: XCTestCase {
    func testTakesContactNameFromURIDisplayNameAndEmptyLabelWhenContactMatchIsNotFound() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let output = ContactCallHistoryRecordsGetUseCaseOutputSpy()
        let sut = ContactCallHistoryRecordsGetUseCase(matching: ContactMatchingStub([:]), output: output)
        let expected = [
            ContactCallHistoryRecord(
                origin: record1,
                contact: Contact(name: record1.uri.displayName, address: makeAddress(uri: record1.uri), label: "")
            ),
            ContactCallHistoryRecord(
                origin: record2,
                contact: Contact(name: record2.uri.displayName, address: makeAddress(uri: record2.uri), label: "")
            )
        ]

        sut.update(records: [record1, record2])

        XCTAssertEqual(output.invokedRecords, expected)
    }

    func testTakesContactNameAndLabelFromContactMatchingResultWhenContactMatchIsFound() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let match1 = ContactMatchingResult(name: "full-name-1", label: "label-1")
        let match2 = ContactMatchingResult(name: "full-name-2", label: "label-2")
        let output = ContactCallHistoryRecordsGetUseCaseOutputSpy()
        let sut = ContactCallHistoryRecordsGetUseCase(
            matching: ContactMatchingStub([record1.uri: match1, record2.uri: match2]), output: output
        )
        let expected = [
            ContactCallHistoryRecord(
                origin: record1,
                contact: Contact(name: match1.name, address: makeAddress(uri: record1.uri), label: match1.label)
            ),
            ContactCallHistoryRecord(
                origin: record2,
                contact: Contact(name: match2.name, address: makeAddress(uri: record2.uri), label: match2.label)
            )
        ]

        sut.update(records: [record1, record2])

        XCTAssertEqual(output.invokedRecords, expected)
    }

    func testAdressIsUserWhenHostIsEmpty() {
        let output = ContactCallHistoryRecordsGetUseCaseOutputSpy()
        let sut = ContactCallHistoryRecordsGetUseCase(matching: ContactMatchingStub([:]), output: output)
        let user = "user-123"

        sut.update(
            records: [
                CallHistoryRecord(
                    uri: URI(user: user, host: "", displayName: "any-name"),
                    date: Date(),
                    duration: 0,
                    isIncoming: false,
                    isMissed: false
                )
            ]
        )

        XCTAssertEqual(output.invokedRecords.first!.contact.address, user)
    }
}

private func makeAddress(uri: URI) -> String {
    return "\(uri.user)@\(uri.host)"
}

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
    func testContactNameIsURIDisplayNameAndLabelIsEmptyWhenContactMatchIsNotFound() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let output = ContactCallHistoryRecordsGetUseCaseOutputSpy()
        let sut = ContactCallHistoryRecordsGetUseCase(matching: ContactMatchingStub([:]), output: output)
        let expected = [
            ContactCallHistoryRecord(
                origin: record1,
                contact: MatchedContact(name: record1.uri.displayName, address: makeEmailAddress(uri: record1.uri, label: ""))
            ),
            ContactCallHistoryRecord(
                origin: record2,
                contact: MatchedContact(name: record2.uri.displayName, address: makeEmailAddress(uri: record2.uri, label: ""))
            )
        ]

        sut.update(records: [record1, record2])

        XCTAssertEqual(output.invokedRecords, expected)
    }

    func testContactIsMatchedContactWhenContactMatchIsFound() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let contact1 = MatchedContact(name: "full-name-1", address: makeEmailAddress(uri: record1.uri, label: "label-1"))
        let contact2 = MatchedContact(name: "full-name-2", address: makeEmailAddress(uri: record2.uri, label: "label-2"))
        let output = ContactCallHistoryRecordsGetUseCaseOutputSpy()
        let sut = ContactCallHistoryRecordsGetUseCase(
            matching: ContactMatchingStub([record1.uri: contact1, record2.uri: contact2]), output: output
        )
        let expected = [
            ContactCallHistoryRecord(origin: record1, contact: contact1),
            ContactCallHistoryRecord(origin: record2, contact: contact2)
        ]

        sut.update(records: [record1, record2])

        XCTAssertEqual(output.invokedRecords, expected)
    }

    func testAdressIsPhoneTakenFromUserWhenContactMatchIsNotFoundAndHostIsEmpty() {
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

        XCTAssertEqual(output.invokedRecords.first!.contact.address, .phone(number: user, label: ""))
    }
}

private func makeEmailAddress(uri: URI, label: String) -> MatchedContact.Address {
    return .email(address: "\(uri.user)@\(uri.host)", label: label)
}

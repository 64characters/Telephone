//
//  CallHistoryCallMakeUseCaseTests.swift
//  Telephone
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

final class CallHistoryCallMakeUseCaseTests: XCTestCase {
    func testMakesCallToURICreatedFromRecordOnUpdate() {
        let record = ContactCallHistoryRecord(
            origin: CallHistoryRecordTestFactory().makeRecord(number: 1),
            contact: MatchedContact(name: "any", address: .email(address: "any", label: "any"))
        )
        let account = AccountSpy()
        let sut = CallHistoryCallMakeUseCase(account: account)

        sut.update(record: record)

        XCTAssertTrue(account.didCallMakeCall)
        XCTAssertEqual(account.invokedURI, URI(record: record))
    }

    func testMakesCallWithLabelFromContactAddressOnUpdate() {
        let label = "any-label"
        let record = ContactCallHistoryRecord(
            origin: CallHistoryRecordTestFactory().makeRecord(number: 1),
            contact: MatchedContact(name: "any", address: .email(address: "any", label: label))
        )
        let account = AccountSpy()
        let sut = CallHistoryCallMakeUseCase(account: account)

        sut.update(record: record)

        XCTAssertTrue(account.didCallMakeCall)
        XCTAssertEqual(account.invokedLabel, label)
    }
}

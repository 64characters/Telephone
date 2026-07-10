//
//  ContactCallHistoryRecordGetUseCaseTests.swift
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

import XCTest
import UseCases
import UseCasesTestDoubles

@ContactsActor
final class ContactCallHistoryRecordGetUseCaseTests: XCTestCase {
    func testCallsUpdateOnOutputWithRecordConvertedUsingMatchedContactFactoryOnUpdate() async {
        let record = CallHistoryRecordTestFactory().makeRecord(number: 1)
        let contact = MatchedContact(uri: record.uri)
        let didUpdate = expectation(description: "Calls update on output")
        let output = ContactCallHistoryRecordGetUseCaseOutputSpy(callback: didUpdate.fulfill)
        let sut = ContactCallHistoryRecordGetUseCase(
            factory: FallingBackMatchedContactFactory(matching: ContactMatchingStub([record.uri: contact])),
            output: output
        )

        sut.update(record: record)

        await fulfillment(of: [didUpdate], timeout: 1)
        XCTAssertEqual(output.invokedRecord, ContactCallHistoryRecord(origin: record, contact: contact))
    }
}

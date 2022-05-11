//
//  ContactCallHistoryRecordGetAllUseCaseTests.swift
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

final class ContactCallHistoryRecordGetAllUseCaseTests: XCTestCase {
    func testCallsUpdateOnOutputWithRecordsConvertedUsingMatchedContactFactoryOnUpdate() {
        let record1 = CallHistoryRecordTestFactory().makeRecord(number: 1)
        let record2 = CallHistoryRecordTestFactory().makeRecord(number: 2)
        let contact1 = MatchedContact(uri: record1.uri)
        let contact2 = MatchedContact(uri: record2.uri)
        let output = ContactCallHistoryRecordGetAllUseCaseOutputSpy()
        let sut = ContactCallHistoryRecordGetAllUseCase(
            factory: FallingBackMatchedContactFactory(
                matching: ContactMatchingStub([record1.uri: contact1, record2.uri: contact2])
            ),
            output: output
        )

        sut.update(records: [record1, record2])

        XCTAssertEqual(
            output.invokedRecords,
            [
                ContactCallHistoryRecord(origin: record1, contact: contact1),
                ContactCallHistoryRecord(origin: record2, contact: contact2)

            ]
        )
    }
}

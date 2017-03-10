//
//  ContactCallHistoryRecordsGetUseCaseTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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
    func testUpdatesOutputOnUpdate() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let output = ContactCallHistoryRecordsGetUseCaseOutputSpy()
        let sut = ContactCallHistoryRecordsGetUseCase(output: output)
        let expected = [makeContactCallHistoryRecord(record: record1), makeContactCallHistoryRecord(record: record2)]

        sut.update(records: [record1, record2])

        XCTAssertEqual(output.invokedRecords, expected)
    }
}

private func makeContactCallHistoryRecord(record: CallHistoryRecord) -> ContactCallHistoryRecord {
    return ContactCallHistoryRecord(origin: record, contact: makeContact(address: record.address))
}

private func makeContact(address: ContactAddress) -> Contact {
    return Contact(
        name: "any-name", address: LabeledContactAddress(origin: address, label: "any-label")
    )
}

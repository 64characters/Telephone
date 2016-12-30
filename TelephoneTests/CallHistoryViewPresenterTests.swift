//
//  CallHistoryViewPresenterTests.swift
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

final class CallHistoryViewPresenterTests: XCTestCase {
    func testShowsRecordsOnRecordsUpdate() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let contact1 = makeContact(record: record1, number: 1)
        let contact2 = makeContact(record: record2, number: 2)
        let view = CallHistoryViewSpy()
        let sut = CallHistoryViewPresenter(view: view, dateFormatter: ShortDateTimeFormatter())
        let expected1 = makePresentationCallHistoryRecord(contact: contact1, record: record1)
        let expected2 = makePresentationCallHistoryRecord(contact: contact2, record: record2)

        sut.update(
            records: [
                ContactCallHistoryRecord(origin: record1, contact: contact1),
                ContactCallHistoryRecord(origin: record2, contact: contact2)
            ]
        )

        XCTAssertEqual(view.invokedRecords, [expected1, expected2])
    }
}

private func makeContact(record: CallHistoryRecord, number: Int) -> Contact {
    return Contact(
        name: "any-name-\(number)", address: LabeledContactAddress(origin: record.address, label: "any-label-\(number)")
    )
}

private func makePresentationCallHistoryRecord(contact: Contact, record: CallHistoryRecord) -> PresentationCallHistoryRecord {
    return PresentationCallHistoryRecord(
        contact: makePresentationContact(contact: contact),
        date: ShortDateTimeFormatter().string(from: record.date),
        duration: "",
        isIncoming: record.isIncoming,
        isMissed: record.isMissed
    )
}

private func makePresentationContact(contact: Contact) -> PresentationContact {
    return PresentationContact(
        name: contact.name,
        address: PresentationContactAddress(
            user: contact.address.origin.user, host: contact.address.origin.host, label: contact.address.label
        )
    )
}

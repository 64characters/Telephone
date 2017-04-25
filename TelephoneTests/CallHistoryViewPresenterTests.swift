//
//  CallHistoryViewPresenterTests.swift
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
        let sut = CallHistoryViewPresenter(
            view: view, dateFormatter: ShortRelativeDateTimeFormatter(), durationFormatter: DurationFormatter()
        )
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

    func testContactColorIsRedForMissedCallRecords() {
        let record = CallHistoryRecord(
            name: "any-name",
            address: ContactAddress(user: "any-user", host: "any-host"),
            date: Date(),
            duration: 0,
            isIncoming: false,
            isMissed: true
        )
        let contact = makeContact(record: record, number: 1)
        let view = CallHistoryViewSpy()
        let sut = CallHistoryViewPresenter(
            view: view, dateFormatter: ShortRelativeDateTimeFormatter(), durationFormatter: DurationFormatter()
        )

        sut.update(records: [ContactCallHistoryRecord(origin: record, contact: contact)])

        XCTAssertEqual(view.invokedRecords.first!.contact.color, NSColor.red)
    }
}

private func makeContact(record: CallHistoryRecord, number: Int) -> Contact {
    return Contact(
        name: "any-name-\(number)", address: LabeledContactAddress(origin: record.address, label: "any-label-\(number)")
    )
}

private func makePresentationCallHistoryRecord(contact: Contact, record: CallHistoryRecord) -> PresentationCallHistoryRecord {
    return PresentationCallHistoryRecord(
        contact: makePresentationContact(contact: contact, color: contactColor(for: record)),
        date: ShortRelativeDateTimeFormatter().string(from: record.date),
        duration: DurationFormatter().string(from: TimeInterval(record.duration))!,
        isIncoming: record.isIncoming
    )
}

private func makePresentationContact(contact: Contact, color: NSColor) -> PresentationContact {
    return PresentationContact(
        name: contact.name,
        address: PresentationContactAddress(
            user: contact.address.origin.user, host: contact.address.origin.host, label: contact.address.label
        ),
        color: color
    )
}

private func contactColor(for record: CallHistoryRecord) -> NSColor {
    return record.isMissed ? NSColor.red : NSColor.controlTextColor
}

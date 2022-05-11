//
//  CallHistoryViewPresenterTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

final class CallHistoryViewPresenterTests: XCTestCase {
    func testShowsRecordsOnRecordsUpdate() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let contact1 = makeContact(number: 1)
        let contact2 = makeContact(number: 2)
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

    func testContactColorIsSystemRedForMissedCallRecords() {
        let record = CallHistoryRecord(
            uri: URI(user: "any-user", host: "any-host", displayName: "any-name"),
            date: Date(),
            duration: 0,
            isIncoming: false,
            isMissed: true
        )
        let contact = makeContact(number: 1)
        let view = CallHistoryViewSpy()
        let sut = CallHistoryViewPresenter(
            view: view, dateFormatter: ShortRelativeDateTimeFormatter(), durationFormatter: DurationFormatter()
        )

        sut.update(records: [ContactCallHistoryRecord(origin: record, contact: contact)])

        XCTAssertEqual(view.invokedRecords.first!.contact.color, NSColor.systemRed)
    }

    func testTitleIsEmailAddressOrPhoneNumberAndTooltipIsEmptyWhenNameIsEmpty() {
        let factory = CallHistoryRecordTestFactory()
        let record1 = factory.makeRecord(number: 1)
        let record2 = factory.makeRecord(number: 2)
        let address = "any-address"
        let number = "any-number"
        let contact1 = MatchedContact(name: "", address: .email(address: address, label: "any-label-1"))
        let contact2 = MatchedContact(name: "", address: .phone(number: number, label: "any-label-2"))
        let view = CallHistoryViewSpy()
        let sut = CallHistoryViewPresenter(
            view: view, dateFormatter: ShortRelativeDateTimeFormatter(), durationFormatter: DurationFormatter()
        )

        sut.update(
            records: [
                ContactCallHistoryRecord(origin: record1, contact: contact1),
                ContactCallHistoryRecord(origin: record2, contact: contact2)
            ]
        )

        XCTAssertEqual(view.invokedRecords[0].contact.title, address)
        XCTAssertTrue(view.invokedRecords[0].contact.tooltip.isEmpty)
        XCTAssertEqual(view.invokedRecords[1].contact.title, number)
        XCTAssertTrue(view.invokedRecords[1].contact.tooltip.isEmpty)
    }
}

private func makeContact(number: Int) -> MatchedContact {
    return MatchedContact(
        name: "any-name-\(number)", address: .email(address: "any-address\(number)", label: "any-label-\(number)")
    )
}

private func makePresentationCallHistoryRecord(contact: MatchedContact, record: CallHistoryRecord) -> PresentationCallHistoryRecord {
    return PresentationCallHistoryRecord(
        identifier: record.identifier,
        contact: makePresentationContact(contact: contact, color: contactColor(for: record)),
        date: ShortRelativeDateTimeFormatter().string(from: record.date),
        duration: DurationFormatter().string(from: TimeInterval(record.duration))!,
        isIncoming: record.isIncoming
    )
}

private func makePresentationContact(contact: MatchedContact, color: NSColor) -> PresentationContact {
    switch contact.address {
    case let .phone(number, label):
        return PresentationContact(title: contact.name, tooltip: number, label: label, color: color, address: number)
    case let .email(address, label):
        return PresentationContact(title: contact.name, tooltip: address, label: label, color: color, address: address)
    }
}

private func contactColor(for record: CallHistoryRecord) -> NSColor {
    return record.isMissed ? NSColor.systemRed : NSColor.controlTextColor
}

//
//  EnqueuingContactCallHistoryRecordGetUseCaseOutputTests.swift
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

final class EnqueuingContactCallHistoryRecordGetUseCaseOutputTests: XCTestCase {
    func testAddsBlockToQueueOnUpdate() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingContactCallHistoryRecordGetUseCaseOutput(
            origin: ContactCallHistoryRecordGetUseCaseOutputSpy(), queue: queue
        )

        sut.update(record: ContactCallHistoryRecord(
            origin: CallHistoryRecordTestFactory().makeRecord(number: 1),
            contact: MatchedContact(name: "any", address: .email(address: "any", label: "any"))
        ))

        XCTAssertTrue(queue.didCallAdd)
    }

    func testCallsUpdateOnOriginWithTheSameArgumentOnUpdate() {
        let origin = ContactCallHistoryRecordGetUseCaseOutputSpy()
        let sut = EnqueuingContactCallHistoryRecordGetUseCaseOutput(origin: origin, queue: SyncExecutionQueue())
        let record = ContactCallHistoryRecord(
            origin: CallHistoryRecordTestFactory().makeRecord(number: 2),
            contact: MatchedContact(name: "any", address: .email(address: "any", label: "any"))
        )

        sut.update(record: record)

        XCTAssertEqual(origin.invokedRecord, record)
    }
}

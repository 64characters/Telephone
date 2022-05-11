//
//  EnqueuingContactCallHistoryRecordGetAllUseCaseOutputTests.swift
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

final class EnqueuingContactCallHistoryRecordGetAllUseCaseOutputTests: XCTestCase {
    func testAddsBlockToQueueOnUpdate() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingContactCallHistoryRecordGetAllUseCaseOutput(
            origin: ContactCallHistoryRecordGetAllUseCaseOutputSpy(), queue: queue
        )

        sut.update(records: [])

        XCTAssertTrue(queue.didCallAdd)
    }

    func testCallsUpdateOnOriginWithTheSameArgumentOnUpdate() {
        let origin = ContactCallHistoryRecordGetAllUseCaseOutputSpy()
        let sut = EnqueuingContactCallHistoryRecordGetAllUseCaseOutput(origin: origin, queue: SyncExecutionQueue())
        let records = [makeRecord(number: 1), makeRecord(number: 2), makeRecord(number: 3)]

        sut.update(records: records)

        XCTAssertEqual(origin.invokedRecords, records)
    }
}

private func makeRecord(number: Int) -> ContactCallHistoryRecord {
    return ContactCallHistoryRecordTestFactory(factory: CallHistoryRecordTestFactory()).makeRecord(number: number)
}

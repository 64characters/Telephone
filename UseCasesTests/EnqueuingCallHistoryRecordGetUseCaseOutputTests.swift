//
//  EnqueuingCallHistoryRecordGetUseCaseOutputTests.swift
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

final class EnqueuingCallHistoryRecordGetUseCaseOutputTests: XCTestCase {
    func testAddsBlockToQueueOnUpdate() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingCallHistoryRecordGetUseCaseOutput(origin: CallHistoryRecordGetUseCaseOutputSpy(), queue: queue)

        sut.update(record: CallHistoryRecordTestFactory().makeRecord(number: 1))

        XCTAssertTrue(queue.didCallAdd)
    }

    func testCallsUpdateOnOriginWithTheSameArgumentOnUpdate() {
        let origin = CallHistoryRecordGetUseCaseOutputSpy()
        let sut = EnqueuingCallHistoryRecordGetUseCaseOutput(origin: origin, queue: SyncExecutionQueue())
        let record = CallHistoryRecordTestFactory().makeRecord(number: 2)

        sut.update(record: record)

        XCTAssertTrue(origin.didCallUpdate)
        XCTAssertEqual(origin.invokedRecord, record)
    }
}

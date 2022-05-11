//
//  CallHistoryRecordRemoveUseCaseTests.swift
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

final class CallHistoryRecordRemoveUseCaseTests: XCTestCase {
    func testRemovesRecord() {
        let record1 = CallHistoryRecordTestFactory().makeRecord(number: 1)
        let record2 = CallHistoryRecordTestFactory().makeRecord(number: 2)
        let record3 = CallHistoryRecordTestFactory().makeRecord(number: 3)
        let history = TruncatingCallHistory()
        history.add(record1)
        history.add(record2)
        history.add(record3)
        let sut = CallHistoryRecordRemoveUseCase(identifier: record1.identifier, history: history)

        sut.execute()

        XCTAssertEqual(history.allRecords, [record2, record3])
    }
}

//
//  CallHistoryRecordGetUseCaseTests.swift
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

import XCTest
import UseCases
import UseCasesTestDoubles

final class CallHistoryRecordGetUseCaseTests: XCTestCase {
    func testCallsUpdateWithRecordAtIndexFromHistoryOnExecute() {
        let factory = CallHistoryRecordTestFactory()
        let history = TruncatingCallHistory()
        history.add(factory.makeRecord(number: 1))
        history.add(factory.makeRecord(number: 2))
        history.add(factory.makeRecord(number: 3))
        history.add(factory.makeRecord(number: 4))
        let index = 2
        let output = CallHistoryRecordGetUseCaseOutputSpy()
        let sut = CallHistoryRecordGetUseCase(history: history, index: index, output: output)

        sut.execute()

        XCTAssertTrue(output.didCallUpdate)
        XCTAssertEqual(output.invokedRecord, history.allRecords[index])
    }
}

//
//  CallHistoryRecordGetUseCaseTests.swift
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

@CallHistoryActor
final class CallHistoryRecordGetUseCaseTests: XCTestCase {
    func testCallsUpdateWithRecordWithIdentifierFromHistoryOnExecute() async {
        let factory = CallHistoryRecordTestFactory()
        let history = TruncatingCallHistory()
        history.add(factory.makeRecord(number: 1))
        history.add(factory.makeRecord(number: 2))
        history.add(factory.makeRecord(number: 3))
        history.add(factory.makeRecord(number: 4))
        let result = history.allRecords[2]
        let didCallUpdate = expectation(description: "Calls update on output")
        var invokedRecord: CallHistoryRecord?
        let output = CallHistoryRecordGetUseCaseOutputSpy { record in
            invokedRecord = record
            didCallUpdate.fulfill()
        }
        let sut = CallHistoryRecordGetUseCase(identifier: result.identifier, history: history, output: output)

        sut.execute()

        await fulfillment(of: [didCallUpdate], timeout: 1)
        XCTAssertEqual(invokedRecord, result)
    }

    func testDoesNotCallUpdateWhenRecordWithGivenIdentifierIsNotFoundOnExecute() async {
        let didNotCallUpdate = expectation(description: "Does not call update on output")
        didNotCallUpdate.isInverted = true
        let output = CallHistoryRecordGetUseCaseOutputSpy { _ in didNotCallUpdate.fulfill() }
        let sut = CallHistoryRecordGetUseCase(identifier: "nonexistent", history: TruncatingCallHistory(), output: output)

        sut.execute()

        await fulfillment(of: [didNotCallUpdate], timeout: 1)
    }
}

//
//  CallHistoryCallMakeUseCaseTests.swift
//  Telephone
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

final class CallHistoryCallMakeUseCaseTests: XCTestCase {
    func testMakesCallWithExpectedURI() {
        let account = AccountSpy()
        let factory = CallHistoryRecordTestFactory()
        let record = factory.makeRecord(number: 2)
        let history = TruncatingCallHistory()
        history.add(factory.makeRecord(number: 1))
        history.add(record)
        history.add(factory.makeRecord(number: 3))
        let sut = CallHistoryCallMakeUseCase(
            account: account, history: history, index: history.allRecords.index(of: record)!
        )

        sut.execute()

        XCTAssertTrue(account.didCallMakeCallTo)
        XCTAssertEqual(account.invokedURI, URI(record.address))
    }
}

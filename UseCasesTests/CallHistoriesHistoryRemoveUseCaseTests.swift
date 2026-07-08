//
//  CallHistoriesHistoryRemoveUseCaseTests.swift
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

@CallHistoryActor
final class CallHistoriesHistoryRemoveUseCaseTests: XCTestCase {
    func testCallsRemoveAllOnHistoryOnDidRemoveAccount() async {
        let uuid = "any-uuid"
        let didCallRemoveAll = expectation(description: "Calls remove all on history")
        let history = CallHistorySpy(addCallback: {}, removeCallback: {}, removeAllCallback: didCallRemoveAll.fulfill)
        let sut = CallHistoriesHistoryRemoveUseCase(histories: CallHistoriesSpy(histories: [uuid: history], removeCallback: { _ in }))

        sut.didRemoveAccount(withUUID: uuid)

        await fulfillment(of: [didCallRemoveAll], timeout: 1)
    }

    func testRemovesHistoryOnDidRemoveAccount() async {
        let uuid = "any-uuid"
        let didCallRemove = expectation(description: "Calls remove on histories")
        var invokedUUID: String?
        let histories = CallHistoriesSpy(
            histories: [uuid: CallHistorySpy(addCallback: {}, removeCallback: {}, removeAllCallback: {})],
            removeCallback: { uuid in
                invokedUUID = uuid
                didCallRemove.fulfill()
            }
        )
        let sut = CallHistoriesHistoryRemoveUseCase(histories: histories)

        sut.didRemoveAccount(withUUID: uuid)

        await fulfillment(of: [didCallRemove], timeout: 1)
        XCTAssertEqual(invokedUUID, uuid)
    }
}

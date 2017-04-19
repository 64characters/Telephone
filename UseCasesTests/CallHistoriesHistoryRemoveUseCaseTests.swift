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

final class CallHistoriesHistoryRemoveUseCaseTests: XCTestCase {
    func testCallsRemoveAllOnHistoryOnDidRemoveAccount() {
        let uuid = "any-uuid"
        let history = CallHistorySpy()
        let sut = CallHistoriesHistoryRemoveUseCase(histories: CallHistoriesSpy(histories: [uuid: history]))

        sut.didRemoveAccount(withUUID: uuid)

        XCTAssertTrue(history.didCallRemoveAll)
    }

    func testRemovesHistoryOnDidRemoveAccount() {
        let uuid = "any-uuid"
        let histories = CallHistoriesSpy(histories: [uuid: CallHistorySpy()])
        let sut = CallHistoriesHistoryRemoveUseCase(histories: histories)

        sut.didRemoveAccount(withUUID: uuid)

        XCTAssertTrue(histories.didCallRemove)
        XCTAssertEqual(histories.invokedUUID, uuid)
    }
}

//
//  CallHistoryViewEventTargetTests.swift
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
import UseCasesTestDoubles

final class CallHistoryViewEventTargetTests: XCTestCase {
    func testExecutesCallHistoryRecordsGetUseCaseOnShouldReloadData() {
        let get = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: get,
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldReloadData()

        XCTAssertTrue(get.didCallExecute)
    }

    func testExecutesCallHistoryRecordsGetUseCaseOnDidUpdateHistory() {
        let get = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: get,
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.didUpdate(TruncatingCallHistory())

        XCTAssertTrue(get.didCallExecute)
    }

    func testCreatesCallHistoryCallMakeUseCaseWithExpectedIndexOnDidPickRecord() {
        let factory = CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: factory
        )

        sut.didPickRecord(at: 3)

        XCTAssertEqual(factory.invokedIndex, 3)
    }

    func testExecutesCallHistoryCallMakeUseCaseOnDidPickRecord() {
        let callMake = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: callMake)
        )

        sut.didPickRecord(at: 1)

        XCTAssertTrue(callMake.didCallExecute)
    }

    func testCreatesCallHistoryRecordRemoveUseCaseWithExpectedIndexOnShouldRemoveRecord() {
        let factory = CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy())
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: factory,
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldRemoveRecord(at: 2)

        XCTAssertEqual(factory.invokedIndex, 2)
    }

    func testExecutesCallHistoryRecordRemoveUseCaseOnShouldRemoveRecord() {
        let remove = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: remove),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldRemoveRecord(at: 0)

        XCTAssertTrue(remove.didCallExecute)
    }
}

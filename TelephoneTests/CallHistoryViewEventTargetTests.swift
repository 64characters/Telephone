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

    func testCreatesCallHistoryCallMakeUseCaseWithExpectedIdentifierOnDidPickRecord() {
        let factory = CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: factory
        )
        let identifier = "any"

        sut.didPickRecord(withIdentifier: identifier)

        XCTAssertEqual(factory.invokedIdentifier, identifier)
    }

    func testExecutesCallHistoryCallMakeUseCaseOnDidPickRecord() {
        let callMake = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: callMake)
        )

        sut.didPickRecord(withIdentifier: "any")

        XCTAssertTrue(callMake.didCallExecute)
    }

    func testCreatesCallHistoryRecordRemoveUseCaseWithExpectedIdentifierOnShouldRemoveRecord() {
        let factory = CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy())
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: factory,
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )
        let identifier = "any"

        sut.shouldRemoveRecord(withIdentifier: identifier)

        XCTAssertEqual(factory.invokedIdentifier, identifier)
    }

    func testExecutesCallHistoryRecordRemoveUseCaseOnShouldRemoveRecord() {
        let remove = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: remove),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldRemoveRecord(withIdentifier: "any")

        XCTAssertTrue(remove.didCallExecute)
    }
}

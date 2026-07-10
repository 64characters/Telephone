//
//  CallHistoryViewEventTargetTests.swift
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

@MainActor
final class CallHistoryViewEventTargetTests: XCTestCase {

    // MARK: - Should reload data

    func testExecutesCallHistoryRecordGetAllUseCaseOnShouldReloadData() {
        let get = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: get,
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldReloadData()

        XCTAssertTrue(get.didCallExecute)
    }

    func testExecutesPurchaseCheckUseCaseOnShouldReloadData() {
        let purchaseCheck = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: purchaseCheck,
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldReloadData()

        XCTAssertTrue(purchaseCheck.didCallExecute)
    }

    // MARK: - Did update history

    func testExecutesCallHistoryRecordGetAllUseCaseOnDidUpdateHistory() {
        let didExecuteRecordsGet = expectation(description: "Calls execute on records get")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(callBack: didExecuteRecordsGet.fulfill),
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.didUpdate(TruncatingCallHistory())

        wait(for: [didExecuteRecordsGet], timeout: 1)
    }

    func testExecutesPurchaseCheckUseCaseOnDidUpdateHistory() {
        let didExecutePurchaseCheck = expectation(description: "Calls execute on purchase check")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: UseCaseSpy(callBack: didExecutePurchaseCheck.fulfill),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.didUpdate(TruncatingCallHistory())

        wait(for: [didExecutePurchaseCheck], timeout: 1)
    }

    // MARK: - Did purchase

    func testExecutesCallHistoryRecordGetAllUseCaseOnDidPurchase() {
        let didExecuteRecordsGet = expectation(description: "Calls execute on records get")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(callBack: didExecuteRecordsGet.fulfill),
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.didPurchase()

        wait(for: [didExecuteRecordsGet], timeout: 1)
    }

    func testExecutesPurchaseCheckUseCaseOnDidPurchase() {
        let didExecutePurchaseCheck = expectation(description: "Calls execute on purchase check")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: UseCaseSpy(callBack: didExecutePurchaseCheck.fulfill),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.didPurchase()

        wait(for: [didExecutePurchaseCheck], timeout: 1)
    }

    // MARK: - Did restore purchases

    func testExecutesCallHistoryRecordGetAllUseCaseOnDidRestorePurchases() {
        let didExecuteRecordsGet = expectation(description: "Calls execute on records get")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(callBack: didExecuteRecordsGet.fulfill),
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.didRestorePurchases()

        wait(for: [didExecuteRecordsGet], timeout: 1)
    }

    func testExecutesPurchaseCheckUseCaseOnDidRestorePurchases() {
        let didExecutePurchaseCheck = expectation(description: "Calls execute on purchase check")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: UseCaseSpy(callBack: didExecutePurchaseCheck.fulfill),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.didRestorePurchases()

        wait(for: [didExecutePurchaseCheck], timeout: 1)
    }

    // MARK: - Day did change

    func testExecutesCallHistoryRecordGetAllUseCaseOnDayDidChange() {
        let didExecuteRecordsGet = expectation(description: "Calls execute on records get")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(callBack: didExecuteRecordsGet.fulfill),
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.dayDidChange()

        wait(for: [didExecuteRecordsGet], timeout: 1)
    }

    func testExecutesPurchaseCheckUseCaseOnDayDidChange() {
        let didExecutePurchaseCheck = expectation(description: "Calls execute on purchase check")
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: UseCaseSpy(callBack: didExecutePurchaseCheck.fulfill),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.dayDidChange()

        wait(for: [didExecutePurchaseCheck], timeout: 1)
    }

    // MARK: - Should remove all records

    func testExecutesCallHistoryRecordRemoveAllUseCaseOnShouldRemoveAllRecords() {
        let remove = UseCaseSpy()
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: remove,
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldRemoveAllRecords()

        XCTAssertTrue(remove.didCallExecute)
    }

    // MARK: - Did pick record

    func testCreatesCallHistoryCallMakeUseCaseWithExpectedIdentifierOnDidPickRecord() {
        let factory = CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
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
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy()),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: callMake)
        )

        sut.didPickRecord(withIdentifier: "any")

        XCTAssertTrue(callMake.didCallExecute)
    }

    // MARK: - Should remove record

    func testCreatesCallHistoryRecordRemoveUseCaseWithExpectedIdentifierOnShouldRemoveRecord() {
        let factory = CallHistoryRecordRemoveUseCaseFactorySpy(remove: UseCaseSpy())
        let sut = CallHistoryViewEventTarget(
            recordsGet: UseCaseSpy(),
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
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
            purchaseCheck: UseCaseSpy(),
            recordRemoveAll: UseCaseSpy(),
            recordRemove: CallHistoryRecordRemoveUseCaseFactorySpy(remove: remove),
            callMake: CallHistoryCallMakeUseCaseFactorySpy(callMake: UseCaseSpy())
        )

        sut.shouldRemoveRecord(withIdentifier: "any")

        XCTAssertTrue(remove.didCallExecute)
    }
}

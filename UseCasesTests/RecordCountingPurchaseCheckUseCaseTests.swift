//
//  RecordCountingPurchaseCheckUseCaseTests.swift
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

final class RecordCountingPurchaseCheckUseCaseTests: XCTestCase {
    func testCallsDidCheckPurchaseWithRecordCountWhenReceiptIsValidOnUpdate() {
        let factory = CallHistoryRecordTestFactory()
        let records = [factory.makeRecord(number: 1), factory.makeRecord(number: 2), factory.makeRecord(number: 3)]
        let output = RecordCountingPurchaseCheckUseCaseOutputSpy()
        let sut = RecordCountingPurchaseCheckUseCase(
            factory: PurchaseCheckUseCaseFactory(receipt: ValidReceipt()), output: output
        )

        sut.update(records: records)

        XCTAssertTrue(output.didCallDidCheckPurchase)
        XCTAssertEqual(output.invokedCount, records.count)
    }

    func testCallsDidFailCheckingPurchaseWhenReceiptIsInvalidOnUpdate() {
        let output = RecordCountingPurchaseCheckUseCaseOutputSpy()
        let sut = RecordCountingPurchaseCheckUseCase(
            factory: PurchaseCheckUseCaseFactory(receipt: InvalidReceipt()), output: output
        )

        sut.update(records: [])

        XCTAssertTrue(output.didCallDidFailCheckingPurchase)
    }

    func testCallsDidFailCheckingPurchaseWhenReceiptDoesNotHaveActivePurchasesOnUpdate() {
        let output = RecordCountingPurchaseCheckUseCaseOutputSpy()
        let sut = RecordCountingPurchaseCheckUseCase(
            factory: PurchaseCheckUseCaseFactory(receipt: NoActivePurchasesReceipt()), output: output
        )

        sut.update(records: [])

        XCTAssertTrue(output.didCallDidFailCheckingPurchase)
    }
}

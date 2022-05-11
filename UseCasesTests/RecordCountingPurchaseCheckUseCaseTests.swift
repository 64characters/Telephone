//
//  RecordCountingPurchaseCheckUseCaseTests.swift
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

final class RecordCountingPurchaseCheckUseCaseTests: XCTestCase {
    func testCallsDidCheckPurchaseWhenReceiptIsValidOnUpdate() {
        let output = RecordCountingPurchaseCheckUseCaseOutputSpy()
        let sut = RecordCountingPurchaseCheckUseCase(
            factory: PurchaseCheckUseCaseFactory(receipt: ValidReceipt()), output: output
        )

        sut.update(records: [])

        XCTAssertTrue(output.didCallDidCheckPurchase)
    }

    func testCallsDidFailCheckingPurchaseWithRecordCountWhenReceiptIsInvalidOnUpdate() {
        let records = makeRecords(count: 5)
        let output = RecordCountingPurchaseCheckUseCaseOutputSpy()
        let sut = RecordCountingPurchaseCheckUseCase(
            factory: PurchaseCheckUseCaseFactory(receipt: InvalidReceipt()), output: output
        )

        sut.update(records: records)

        XCTAssertTrue(output.didCallDidFailCheckingPurchase)
        XCTAssertEqual(output.invokedCount, records.count)
    }

    func testCallsDidFailCheckingPurchaseWithRecordCountWhenReceiptDoesNotHaveActivePurchasesOnUpdate() {
        let records = makeRecords(count: 6)
        let output = RecordCountingPurchaseCheckUseCaseOutputSpy()
        let sut = RecordCountingPurchaseCheckUseCase(
            factory: PurchaseCheckUseCaseFactory(receipt: NoActivePurchasesReceipt()), output: output
        )

        sut.update(records: records)

        XCTAssertTrue(output.didCallDidFailCheckingPurchase)
        XCTAssertEqual(output.invokedCount, records.count)
    }
}

private func makeRecords(count: Int) -> [CallHistoryRecord] {
    var result: [CallHistoryRecord] = []
    let factory = CallHistoryRecordTestFactory()
    for n in 0..<count {
        result.append(factory.makeRecord(number: n))
    }
    return result
}

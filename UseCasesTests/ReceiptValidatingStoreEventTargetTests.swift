//
//  ReceiptValidatingStoreEventTargetTests.swift
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

final class ReceiptValidatingStoreEventTargetTests: XCTestCase {

    // MARK: - Purchase start

    func testCallsDidStartPurchasingOnDidStartPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())
        let identifier = "any"

        sut.didStartPurchasingProduct(withIdentifier: identifier)

        XCTAssertTrue(origin.didCallDidStartPurchasing)
        XCTAssertEqual(origin.invokedIdentifier, identifier)
    }

    // MARK: - Purchase finish

    func testCallsDidPurchaseWhenReceiptIsValidOnDidPurchase() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: ValidReceipt())

        sut.didPurchase()

        XCTAssertTrue(origin.didCallDidPurchase)
    }

    func testCallsDidFailPurchasingWhenReceiptIsNotValidOnDidPurchase() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didPurchase()

        XCTAssertTrue(origin.didCallDidFailPurchasing)
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.receiptIsInvalid.localizedDescription)
    }

    func testCallsDidFailPurchasingWhenThereAreNoActivePurchasesOnDidPurchase() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: NoActivePurchasesReceipt())

        sut.didPurchase()

        XCTAssertTrue(origin.didCallDidFailPurchasing)
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.noActivePurchases.localizedDescription)
    }

    func testCallsDidFailPurchasingOnDidFailPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())
        let error = "any"

        sut.didFailPurchasing(error: error)

        XCTAssertTrue(origin.didCallDidFailPurchasing)
        XCTAssertEqual(origin.invokedError, error)
    }

    func testCallsDidCancelPurchasingOnDidCancelPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didCancelPurchasing()

        XCTAssertTrue(origin.didCallDidCancelPurchasing)
    }

    // MARK: - Restoration finish

    func testCallsDidRestoreWhenReceiptIsValidOnDidRestore() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: ValidReceipt())

        sut.didRestorePurchases()

        XCTAssertTrue(origin.didCallDidRestore)
    }

    func testCallsDidFailRestoringWhenReceiptIsNotValidOnDidRestore() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didRestorePurchases()

        XCTAssertTrue(origin.didCallDidFailRestoring)
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.receiptIsInvalid.localizedDescription)
    }

    func testCallsDidFailRestoringWhenThereAreNoActivePurchasesOnDidPurchase() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: NoActivePurchasesReceipt())

        sut.didRestorePurchases()

        XCTAssertTrue(origin.didCallDidFailRestoring)
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.noActivePurchases.localizedDescription)
    }

    func testCallsDidFailRestoringOnDidFailRestoring() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())
        let error = "any"

        sut.didFailRestoringPurchases(error: error)

        XCTAssertTrue(origin.didCallDidFailRestoring)
        XCTAssertEqual(origin.invokedError, error)
    }

    func testCallsDidCancelRestoringOnDidCancelRestoring() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didCancelRestoringPurchases()

        XCTAssertTrue(origin.didCallDidCancelRestoring)
    }
}

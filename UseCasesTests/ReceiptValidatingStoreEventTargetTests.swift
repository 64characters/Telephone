//
//  ReceiptValidatingStoreEventTargetTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

        sut.didPurchaseProducts()

        XCTAssertTrue(origin.didCallDidPurchase)
    }

    func testCallsDidFailPurchasingWhenReceiptIsNotValidOnDidPurchase() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didPurchaseProducts()

        XCTAssertTrue(origin.didCallDidFailPurchasing)
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.ReceiptIsInvalid.message)
    }

    func testCallsDidFailPurchasingWhenThereAreNoActivePurchasesOnDidPurchase() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: NoActivePurchasesReceipt())

        sut.didPurchaseProducts()

        XCTAssertTrue(origin.didCallDidFailPurchasing)
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.NoActivePurchases.message)
    }

    func testCallsDidFailPurchasingOnDidFailPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())
        let error = "any"

        sut.didFailPurchasingProducts(error: error)

        XCTAssertTrue(origin.didCallDidFailPurchasing)
        XCTAssertEqual(origin.invokedError, error)
    }

    func testCallsDidCancelPurchasingOnDidCancelPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didCancelPurchasingProducts()

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
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.ReceiptIsInvalid.message)
    }

    func testCallsDidFailRestoringWhenThereAreNoActivePurchasesOnDidPurchase() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: NoActivePurchasesReceipt())

        sut.didRestorePurchases()

        XCTAssertTrue(origin.didCallDidFailRestoring)
        XCTAssertEqual(origin.invokedError, ReceiptValidationResult.NoActivePurchases.message)
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

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

import Testing
import UseCases
import UseCasesTestDoubles

@MainActor
struct ReceiptValidatingStoreEventTargetTests {

    // MARK: - Purchase start

    @Test func callsDidStartPurchasingOnDidStartPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())
        let identifier = "any"

        sut.didStartPurchasingProduct(withIdentifier: identifier)

        #expect(origin.didCallDidStartPurchasing)
        #expect(origin.invokedIdentifier == identifier)
    }

    // MARK: - Purchase finish

    @Test func callsDidPurchaseWhenReceiptIsValidOnDidPurchase() async {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: ValidReceipt())

        await sut.didPurchase()

        #expect(origin.didCallDidPurchase)
    }

    @Test func callsDidFailPurchasingWhenReceiptIsNotValidOnDidPurchase() async {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        await sut.didPurchase()

        #expect(origin.didCallDidFailPurchasing)
        #expect(origin.invokedError == ReceiptValidationResult.receiptIsInvalid.localizedDescription)
    }

    @Test func callsDidFailPurchasingWhenThereAreNoActivePurchasesOnDidPurchase() async {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: NoActivePurchasesReceipt())

        await sut.didPurchase()

        #expect(origin.didCallDidFailPurchasing)
        #expect(origin.invokedError == ReceiptValidationResult.noActivePurchases.localizedDescription)
    }

    @Test func callsDidFailPurchasingOnDidFailPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())
        let error = "any"

        sut.didFailPurchasing(error: error)

        #expect(origin.didCallDidFailPurchasing)
        #expect(origin.invokedError == error)
    }

    @Test func callsDidCancelPurchasingOnDidCancelPurchasing() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didCancelPurchasing()

        #expect(origin.didCallDidCancelPurchasing)
    }

    // MARK: - Restoration finish

    @Test func callsDidRestoreWhenReceiptIsValidOnDidRestore() async {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: ValidReceipt())

        await sut.didRestorePurchases()

        #expect(origin.didCallDidRestore)
    }

    @Test func callsDidFailRestoringWhenReceiptIsNotValidOnDidRestore() async {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        await sut.didRestorePurchases()

        #expect(origin.didCallDidFailRestoring)
        #expect(origin.invokedError == ReceiptValidationResult.receiptIsInvalid.localizedDescription)
    }

    @Test func callsDidFailRestoringWhenThereAreNoActivePurchasesOnDidPurchase() async {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: NoActivePurchasesReceipt())

        await sut.didRestorePurchases()

        #expect(origin.didCallDidFailRestoring)
        #expect(origin.invokedError == ReceiptValidationResult.noActivePurchases.localizedDescription)
    }

    @Test func callsDidFailRestoringOnDidFailRestoring() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())
        let error = "any"

        sut.didFailRestoringPurchases(error: error)

        #expect(origin.didCallDidFailRestoring)
        #expect(origin.invokedError == error)
    }

    @Test func callsDidCancelRestoringOnDidCancelRestoring() {
        let origin = StoreEventTargetSpy()
        let sut = ReceiptValidatingStoreEventTarget(origin: origin, receipt: InvalidReceipt())

        sut.didCancelRestoringPurchases()

        #expect(origin.didCallDidCancelRestoring)
    }
}

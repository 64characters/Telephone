//
//  DefaultStoreViewEventTargetTests.swift
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

final class DefaultStoreViewEventTargetTests: XCTestCase {

    // MARK: - Purchase check

    func testExecutesPurchaseCheckOnCheckPurchase() {
        let check = UseCaseSpy()
        let factory = StoreUseCaseFactorySpy()
        factory.stub(withPurchaseCheck: check)
        let sut = DefaultStoreViewEventTarget(
            factory: factory, purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: StoreViewPresenterSpy()
        )

        sut.checkPurchase()

        XCTAssertTrue(check.didCallExecute)
    }

    func testShowsPurchaseCheckProgressOnCheckPurchase() {
        let factory = StoreUseCaseFactorySpy()
        factory.stub(withPurchaseCheck: UseCaseSpy())
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: factory, purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter)

        sut.checkPurchase()

        XCTAssertTrue(presenter.didCallShowPurchaseCheckProgress)
    }

    // MARK: - Fetch

    func testExecutesProductsFetchOnFetchProducts() {
        let useCase = UseCaseSpy()
        let factory = StoreUseCaseFactorySpy()
        factory.stub(withProductsFetch: useCase)
        let sut = DefaultStoreViewEventTarget(
            factory: factory, purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: StoreViewPresenterSpy()
        )

        sut.fetchProducts()

        XCTAssertTrue(useCase.didCallExecute)
    }

    func testShowsProductsFetchProgressOnFetchProducts() {
        let factory = StoreUseCaseFactorySpy()
        factory.stub(withProductsFetch: UseCaseSpy())
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: factory, purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter)

        sut.fetchProducts()

        XCTAssertTrue(presenter.didCallShowProductsFetchProgress)
    }

    func testShowsProductsOnShowProducts() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let products = SimpleProductsFake().all

        sut.show(products)

        XCTAssertEqual(presenter.invokedProducts, products)
    }

    func testShowsProductsFetchErrorOnShowProductsFetchError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let error = "any"

        sut.showProductsFetchError(error)

        XCTAssertEqual(presenter.invokedProductsFetchError, error)
    }

    // MARK: - Purchase

    func testExecutesProductPurchaseWithGivenIdentifierOnPurchaseProduct() {
        let factory = StoreUseCaseFactorySpy()
        let purchase = ThrowingUseCaseSpy()
        factory.stub(withProductPurchase: purchase)
        let sut = DefaultStoreViewEventTarget(
            factory: factory, purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: StoreViewPresenterSpy()
        )
        let identifier = "any"

        sut.purchaseProduct(withIdentifier: identifier)

        XCTAssertEqual(factory.invokedIdentifier, identifier)
        XCTAssertTrue(purchase.didCallExecute)
    }

    func testShowsPurchaseProgressOnShowPurchaseProgress() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )

        sut.showPurchaseProgress()

        XCTAssertTrue(presenter.didCallShowPurchaseProgress)
    }

    func testShowsCachedProductsOnShowPurchaseError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let products = SimpleProductsFake().all
        sut.show(products)

        sut.showCachedProductsAndPurchaseError("any")

        XCTAssertEqual(presenter.invokedProducts, products)
        XCTAssertEqual(presenter.showProductsCallCount, 2)
    }

    func testShowsPurchaseErrorOnShowPurchaseError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let error = "any"

        sut.showCachedProductsAndPurchaseError(error)

        XCTAssertEqual(presenter.invokedPurchaseError, error)
    }

    // MARK: - Restoration

    func testExecutesPurchaseRestorationOnRestorePurchases() {
        let restoration = UseCaseSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: restoration, receiptRefresh: UseCaseSpy(), presenter: StoreViewPresenterSpy()
        )

        sut.restorePurchases()

        XCTAssertTrue(restoration.didCallExecute)
    }

    func testShowsPurchaseRestorationProgressOnRestorePurchases() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )

        sut.restorePurchases()

        XCTAssertTrue(presenter.didCallShowPurchaseRestorationProgress)
    }

    func testShowsCachedProductsOnShowCachedProductsAndRestoreError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let products = SimpleProductsFake().all
        sut.show(products)

        sut.showCachedProductsAndRestoreError("any")

        XCTAssertEqual(presenter.invokedProducts, products)
        XCTAssertEqual(presenter.showProductsCallCount, 2)
    }

    func testShowsPurchaseRestorationErrorOnShowCachedProductsAndRestoreError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let error = "any"

        sut.showCachedProductsAndRestoreError(error)

        XCTAssertEqual(presenter.invokedPurchaseRestorationError, error)
    }

    func testShowsCachedFetchErrorOnShowCachedFetchErrorAndRestoreError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let error = "any1"
        sut.showProductsFetchError(error)

        sut.showCachedFetchErrorAndRestoreError("any2")

        XCTAssertEqual(presenter.invokedProductsFetchError, error)
        XCTAssertEqual(presenter.showProductsFetchErrorCallCount, 2)
    }

    func testShowsPurchaseRestorationErrorOnShowCachedFetchErrorAndRestoreError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let error = "any"

        sut.showCachedFetchErrorAndRestoreError(error)

        XCTAssertEqual(presenter.invokedPurchaseRestorationError, error)
    }

    func testShowsCahcedFetchErrorOnShowCachedFetchError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let error = "any1"
        sut.showProductsFetchError(error)

        sut.showCachedFetchError()

        XCTAssertEqual(presenter.invokedProductsFetchError, error)
        XCTAssertEqual(presenter.showProductsFetchErrorCallCount, 2)
    }

    // MARK: - Receipt refresh

    func testExecutesReceiptRefreshOnRefreshReceipt() {
        let refresh = UseCaseSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: refresh, presenter: StoreViewPresenterSpy()
        )

        sut.refreshReceipt()

        XCTAssertTrue(refresh.didCallExecute)
    }

    // MARK: - Purchased

    func testShowsPurchasedOnShowThankYou() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(
            factory: StoreUseCaseFactorySpy(), purchaseRestoration: UseCaseSpy(), receiptRefresh: UseCaseSpy(), presenter: presenter
        )
        let date = Date()

        sut.showThankYou(expiration: date)

        XCTAssertTrue(presenter.didCallShowPurchased)
        XCTAssertEqual(presenter.invokedDate, date)
    }
}

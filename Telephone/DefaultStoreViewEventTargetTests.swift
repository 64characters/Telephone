//
//  DefaultStoreViewEventTargetTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

class DefaultStoreViewEventTargetTests: XCTestCase {
    func testExecutesProductsFetchOnFetchProducts() {
        let useCase = UseCaseSpy()
        let factory = StoreUseCaseFactorySpy()
        factory.stub(withProductsFetch: useCase)
        let sut = DefaultStoreViewEventTarget(factory: factory, presenter: StoreViewPresenterSpy())

        sut.fetchProducts()

        XCTAssertTrue(useCase.didCallExecute)
    }

    func testShowsProductsFetchProgressOnFetchProducts() {
        let factory = StoreUseCaseFactorySpy()
        factory.stub(withProductsFetch: UseCaseSpy())
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: factory, presenter: presenter)

        sut.fetchProducts()

        XCTAssertTrue(presenter.didCallShowProductsFetchProgress)
    }

    func testShowsProductsOnShowProducts() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: StoreUseCaseFactorySpy(), presenter: presenter)
        let products = SimpleProductsFake().all

        sut.showProducts(products)

        XCTAssertEqual(presenter.invokedProducts, products)
    }

    func testShowsProductsFetchErrorOnShowProductsFetchError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: StoreUseCaseFactorySpy(), presenter: presenter)
        let error = "any"

        sut.showProductsFetchError(error)

        XCTAssertEqual(presenter.invokedProductsFetchError, error)
    }

    func testExecutesProductPurchaseWithGivenIdentifierOnPurchaseProduct() {
        let factory = StoreUseCaseFactorySpy()
        let purchase = ThrowingUseCaseSpy()
        factory.stub(withProductPurchase: purchase)
        let sut = DefaultStoreViewEventTarget(factory: factory, presenter: StoreViewPresenterSpy())
        let identifier = "any"

        sut.purchaseProduct(withIdentifier: identifier)

        XCTAssertEqual(factory.invokedIdentifier, identifier)
        XCTAssertTrue(purchase.didCallExecute)
    }

    func testShowsPurchaseProgressOnShowPurchaseProgress() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: StoreUseCaseFactorySpy(), presenter: presenter)

        sut.showPurchaseProgress()

        XCTAssertTrue(presenter.didCallShowPurchaseProgress)
    }

    func testShowsCachedProductsOnShowPurchaseError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: StoreUseCaseFactorySpy(), presenter: presenter)
        let products = SimpleProductsFake().all
        sut.showProducts(products)

        sut.showPurchaseError("any")

        XCTAssertEqual(presenter.invokedProducts, products)
        XCTAssertEqual(presenter.showProductsCallCount, 2)
    }

    func testShowsPurchaseErrorOnShowPurchaseError() {
        let presenter = StoreViewPresenterSpy()
        let sut = DefaultStoreViewEventTarget(factory: StoreUseCaseFactorySpy(), presenter: presenter)
        let error = "any"

        sut.showPurchaseError(error)

        XCTAssertEqual(presenter.invokedPurchaseError, error)
    }
}

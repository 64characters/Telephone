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
        let interactor = InteractorSpy()
        let factory = StoreInteractorFactorySpy()
        factory.stub(withProductsFetchInteractor: interactor)
        let sut = DefaultStoreViewEventTarget(interactorFactory: factory, presenterFactory: StorePresenterFactory(output: StoreViewDummy()))

        sut.fetchProducts()

        XCTAssertTrue(interactor.didCallExecute)
    }

    func testShowsProductsOnShowProducts() {
        let view = StoreViewSpy()
        let sut = DefaultStoreViewEventTarget(
            interactorFactory: StoreInteractorFactorySpy(), presenterFactory: StorePresenterFactory(output: view)
        )
        let product1 = Product(identifier: "123", name: "abc", price: NSDecimalNumber(integer: 1), localizedPrice: "$1")
        let product2 = Product(identifier: "456", name: "def", price: NSDecimalNumber(integer: 2), localizedPrice: "$2")

        sut.showProducts([product1, product2])

        XCTAssertEqual(view.invokedProducts, [PresentationProduct(product1), PresentationProduct(product2)])
    }

    func testShowsProductsFetchErrorOnShowProductsFetchError() {
        let view = StoreViewSpy()
        let sut = DefaultStoreViewEventTarget(
            interactorFactory: StoreInteractorFactorySpy(), presenterFactory: StorePresenterFactory(output: view)
        )
        let error = "any"

        sut.showProductsFetchError(error)

        XCTAssertEqual(view.invokedError, error)
    }
}

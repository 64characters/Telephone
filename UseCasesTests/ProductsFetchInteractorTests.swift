//
//  ProductsFetchInteractorTests.swift
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

class ProductsFetchInteractorTests: XCTestCase {
    func testUsesConfiguredIdentifiersWhenFetching() {
        let identifiers = ["any1", "any2"]
        let client = StoreClientSpy()
        let sut = ProductsFetchInteractor(
            productIdentifiers: identifiers,
            client: client,
            targets: StoreClientEventTargets(),
            output: ProductsFetchInteractorOutputSpy()
        )

        sut.execute()

        XCTAssertEqual(client.invokedIdentifiers, identifiers)
    }

    func testCallsOutputWithFetchedProducts() {
        let client = StoreClientSpy()
        let output = ProductsFetchInteractorOutputSpy();
        let sut = ProductsFetchInteractor(
            productIdentifiers: [], client: client, targets: StoreClientEventTargets(), output: output
        )
        let products = [
            Product(identifier: "123", name: "product1", price: NSDecimalNumber(integer: 100), localizedPrice: "$100"),
            Product(identifier: "456", name: "product2", price: NSDecimalNumber(integer: 200), localizedPrice: "$200")
        ]

        sut.storeClient(client, didFetchProducts: products)

        XCTAssertEqual(output.invokedProducts, products)
    }

    func testCallsOutputWithErrorMessageWhenProductFetchFails() {
        let client = StoreClientSpy()
        let output = ProductsFetchInteractorOutputSpy();
        let sut = ProductsFetchInteractor(
            productIdentifiers: [], client: client, targets: StoreClientEventTargets(), output: output
        )
        let error = "any"

        sut.storeClient(client, didFailFetchingProductsWithError: error)

        XCTAssertEqual(output.invokedError, error)
    }

    func testAddsItselfToEventTargetCompositeOnExecution() {
        let targets = StoreClientEventTargets()
        let sut = ProductsFetchInteractor(
            productIdentifiers: [], client: StoreClientSpy(), targets: targets, output: ProductsFetchInteractorOutputSpy()
        )

        sut.execute()

        XCTAssertTrue(targets[0] === sut)
    }

    func testRemovesItselfFromEventTargetCompositeOnFetchSuccess() {
        let targets = StoreClientEventTargets()
        let sut = ProductsFetchInteractor(
            productIdentifiers: [], client: StoreClientSpy(), targets: targets, output: ProductsFetchInteractorOutputSpy()
        )
        sut.execute()

        sut.storeClient(StoreClientSpy(), didFetchProducts: [])

        XCTAssertEqual(targets.count, 0)
    }

    func testRemovesItselfFromEventTargetCompositeOnFetchFailure() {
        let targets = StoreClientEventTargets()
        let sut = ProductsFetchInteractor(
            productIdentifiers: [], client: StoreClientSpy(), targets: targets, output: ProductsFetchInteractorOutputSpy()
        )
        sut.execute()

        sut.storeClient(StoreClientSpy(), didFailFetchingProductsWithError: "any")

        XCTAssertEqual(targets.count, 0)
    }
}

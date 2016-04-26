//
//  ProductFetchInteractorTests.swift
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

class ProductFetchInteractorTests: XCTestCase {
    func testUsesConfiguredIdentifiersWhenFetching() {
        let identifiers = ["any1", "any2"]
        let client = StoreClientSpy()
        let sut = ProductFetchInteractor(productIdentifiers: identifiers, client: client, output: ProductFetchInteractorOutputSpy())

        sut.execute()

        XCTAssertEqual(client.invokedIdentifiers, identifiers)
    }

    func testCallsOutputWithFetchedProducts() {
        let output = ProductFetchInteractorOutputSpy()
        let sut = ProductFetchInteractor(productIdentifiers: [], client: StoreClientSpy(), output: output)
        let products = [
            Product(identifier: "123", name: "product1", price: "$100"),
            Product(identifier: "456", name: "product2", price: "$200")
        ]

        sut.storeClient(StoreClientSpy(), didFetchProducts: products)

        XCTAssertEqual(output.invokedProducts, products)
    }
}

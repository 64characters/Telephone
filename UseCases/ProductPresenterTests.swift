//
//  ProductPresenterTests.swift
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

class ProductPresenterTests: XCTestCase {
    private var output: ProductPresenterOutputSpy!
    private var sut: ProductPresenter!

    override func setUp() {
        super.setUp()
        output = ProductPresenterOutputSpy()
        sut = ProductPresenter(output: output)
    }

    func testShowsProductsSortedByPriceOnUpdate() {
        let product1 = Product(identifier: "123", name: "abc", price: NSDecimalNumber(integer: 3), localizedPrice: "$3")
        let product2 = Product(identifier: "456", name: "def", price: NSDecimalNumber(integer: 1), localizedPrice: "$1")
        let product3 = Product(identifier: "789", name: "ghi", price: NSDecimalNumber(integer: 2), localizedPrice: "$2")

        sut.didFetchProducts([product1, product2, product3])

        XCTAssertEqual(
            output.invokedProducts,
            [PresentationProduct(product2), PresentationProduct(product3), PresentationProduct(product1)]
        )
    }

    func testShowsErrorOnError() {
        let error = "any"

        sut.didFailFetchingProducts(error)

        XCTAssertEqual(output.invokedError, error)
    }
}

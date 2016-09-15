//
//  ProductsEventTargetsTests.swift
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

final class ProductsEventTargetsTests: XCTestCase {
    func testCanAddTargets() {
        let first = ProductsEventTargetSpy()
        let second = ProductsEventTargetSpy()
        let sut = ProductsEventTargets()

        sut.add(first)
        sut.add(second)

        XCTAssertEqual(sut.count, 2)
        XCTAssertTrue(sut[0] === first)
        XCTAssertTrue(sut[1] === second)
    }

    func testCanRemoveTargets() {
        let first = ProductsEventTargetSpy()
        let second = ProductsEventTargetSpy()
        let sut = ProductsEventTargets()
        sut.add(first)
        sut.add(second)

        sut.remove(first)

        XCTAssertEqual(sut.count, 1)
        XCTAssertTrue(sut[0] === second)
    }

    func testCallsDidFetchProductsOnAllTargets() {
        let first = ProductsEventTargetSpy()
        let second = ProductsEventTargetSpy()
        let sut = ProductsEventTargets()
        sut.add(first)
        sut.add(second)

        sut.productsDidFetch()

        XCTAssertTrue(first.didCallProductsDidFetch)
        XCTAssertTrue(second.didCallProductsDidFetch)
    }

    func testCallsDidFailFetchingProductsOnAllTargets() {
        let first = ProductsEventTargetSpy()
        let second = ProductsEventTargetSpy()
        let sut = ProductsEventTargets()
        sut.add(first)
        sut.add(second)

        sut.productsDidFailFetching(error: "any")

        XCTAssertTrue(first.didCallProductsDidFailFetching)
        XCTAssertTrue(second.didCallProductsDidFailFetching)
    }
}

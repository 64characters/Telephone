//
//  ProductsEventTargetsTests.swift
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

    func testCallsDidFetchOnAllTargets() {
        let first = ProductsEventTargetSpy()
        let second = ProductsEventTargetSpy()
        let sut = ProductsEventTargets()
        sut.add(first)
        sut.add(second)

        sut.didFetch(SimpleProductsFake())

        XCTAssertTrue(first.didCallDidFetch)
        XCTAssertTrue(second.didCallDidFetch)
    }

    func testCallsDidFailFetchingOnAllTargets() {
        let first = ProductsEventTargetSpy()
        let second = ProductsEventTargetSpy()
        let sut = ProductsEventTargets()
        sut.add(first)
        sut.add(second)

        sut.didFailFetching(SimpleProductsFake(), error: "any")

        XCTAssertTrue(first.didCallDidFailFetching)
        XCTAssertTrue(second.didCallDidFailFetching)
    }
}

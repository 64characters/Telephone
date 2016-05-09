//
//  StoreClientEventTargetCompositeTests.swift
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

class StoreClientEventTargetCompositeTests: XCTestCase {
    func testCanAddTargets() {
        let first = StoreClientEventTargetSpy()
        let second = StoreClientEventTargetSpy()
        let sut = StoreClientEventTargetComposite()

        sut.addTarget(first)
        sut.addTarget(second)

        XCTAssertEqual(sut.targetsCount, 2)
        XCTAssertTrue(sut[0] === first)
        XCTAssertTrue(sut[1] === second)
    }

    func testCanRemoveTargets() {
        let first = StoreClientEventTargetSpy()
        let second = StoreClientEventTargetSpy()
        let sut = StoreClientEventTargetComposite()
        sut.addTarget(first)
        sut.addTarget(second)

        sut.removeTarget(first)

        XCTAssertEqual(sut.targetsCount, 1)
        XCTAssertTrue(sut[0] === second)
    }

    func testCallsDidFetchProductsOnAllTargets() {
        let first = StoreClientEventTargetSpy()
        let second = StoreClientEventTargetSpy()
        let sut = StoreClientEventTargetComposite()
        sut.addTarget(first)
        sut.addTarget(second)

        sut.storeClient(StoreClientSpy(), didFetchProducts: [])

        XCTAssertTrue(first.didCallDidFetchProducts)
        XCTAssertTrue(second.didCallDidFetchProducts)
    }

    func testCallsDidFailFetchingProductsOnAllTargets() {
        let first = StoreClientEventTargetSpy()
        let second = StoreClientEventTargetSpy()
        let sut = StoreClientEventTargetComposite()
        sut.addTarget(first)
        sut.addTarget(second)

        sut.storeClient(StoreClientSpy(), didFailFetchingProductsWithError: "any-error")

        XCTAssertTrue(first.didCallDidFailFetchingProducts)
        XCTAssertTrue(second.didCallDidFailFetchingProducts)
    }
}

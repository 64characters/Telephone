//
//  StoreEventTargetsTests.swift
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

final class StoreEventTargetsTests: XCTestCase {
    func testCallsDidStartPurchasingProductWithPassedArgumentOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets()
        sut.add(first)
        sut.add(second)
        let identifier = "any"

        sut.didStartPurchasingProduct(withIdentifier: identifier)

        XCTAssertTrue(first.didCallDidStartPurchasing)
        XCTAssertEqual(first.invokedIdentifier, identifier)
        XCTAssertTrue(second.didCallDidStartPurchasing)
        XCTAssertEqual(second.invokedIdentifier, identifier)
    }

    func testCallsDidPurchaseOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets()
        sut.add(first)
        sut.add(second)

        sut.didPurchase()

        XCTAssertTrue(first.didCallDidPurchase)
        XCTAssertTrue(second.didCallDidPurchase)
    }

    func testCallsDidFailPurchasingWithPassedArgumentOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets()
        sut.add(first)
        sut.add(second)
        let error = "any"

        sut.didFailPurchasing(error: error)

        XCTAssertTrue(first.didCallDidFailPurchasing)
        XCTAssertEqual(first.invokedError, error)
        XCTAssertTrue(second.didCallDidFailPurchasing)
        XCTAssertEqual(second.invokedError, error)
    }

    func testCallsDidCancelPurchasingOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets()
        sut.add(first)
        sut.add(second)

        sut.didCancelPurchasing()

        XCTAssertTrue(first.didCallDidCancelPurchasing)
        XCTAssertTrue(second.didCallDidCancelPurchasing)
    }

    func testCallsDidRestorePurchasesOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets()
        sut.add(first)
        sut.add(second)

        sut.didRestorePurchases()

        XCTAssertTrue(first.didCallDidRestore)
        XCTAssertTrue(second.didCallDidRestore)
    }

    func testCallsDidFailRestoringPurchasesWithPassedArgumentOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets()
        sut.add(first)
        sut.add(second)
        let error = "any"

        sut.didFailRestoringPurchases(error: error)

        XCTAssertTrue(first.didCallDidFailRestoring)
        XCTAssertEqual(first.invokedError, error)
        XCTAssertTrue(second.didCallDidFailRestoring)
        XCTAssertEqual(second.invokedError, error)
    }

    func testCallsDidCancelRestoringPurchasesOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets()
        sut.add(first)
        sut.add(second)

        sut.didCancelRestoringPurchases()

        XCTAssertTrue(first.didCallDidCancelRestoring)
        XCTAssertTrue(second.didCallDidCancelRestoring)
    }
}

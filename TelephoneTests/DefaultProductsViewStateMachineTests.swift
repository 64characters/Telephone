//
//  DefaultProductsViewStateMachineTests.swift
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

import XCTest

class DefaultProductsViewStateMachineTests: XCTestCase {
    private var sut: DefaultProductsViewStateMachine!
    private var actions: String!

    override func setUp() {
        super.setUp()
        sut = DefaultProductsViewStateMachine(target: self)
        actions = ""
    }

    func testNormalPurchase() {
        sut.handleEvent(.ViewShouldReload)
        sut.handleEvent(.DidFetch)
        sut.handleEvent(.DidClickPurchase)
        sut.handleEvent(.DidPurchase)

        XCTAssertEqual(actions, "FSpPS")
    }

    func testNormalRestoration() {
        sut.handleEvent(.DidClickRestore)
        sut.handleEvent(.DidRestore)

        XCTAssertEqual(actions, "RS")
    }

    func testProductFetchFailureAndReload() {
        sut.handleEvent(.ViewShouldReload)
        sut.handleEvent(.FetchDidFail)
        sut.handleEvent(.DidClickReload)
        sut.handleEvent(.DidFetch)

        XCTAssertEqual(actions, "FFeFSp")
    }

    func testRestorationAfterProductFetchFailure() {
        sut.handleEvent(.ViewShouldReload)
        sut.handleEvent(.FetchDidFail)
        sut.handleEvent(.DidClickRestore)
        sut.handleEvent(.DidRestore)

        XCTAssertEqual(actions, "FFeRS")
    }

    func testPurchaseFailure() {
        sut.handleEvent(.ViewShouldReload)
        sut.handleEvent(.DidFetch)
        sut.handleEvent(.DidClickPurchase)
        sut.handleEvent(.PurchaseDidFail)

        XCTAssertEqual(actions, "FSpPPe")
    }

    func testPurchaseAfterPurchaseFailure() {
        sut.handleEvent(.ViewShouldReload)
        sut.handleEvent(.DidFetch)
        sut.handleEvent(.DidClickPurchase)
        sut.handleEvent(.PurchaseDidFail)
        sut.handleEvent(.DidClickPurchase)
        sut.handleEvent(.DidPurchase)

        XCTAssertEqual(actions, "FSpPPePS")
    }

    func testRestorationFailure() {
        sut.handleEvent(.DidClickRestore)
        sut.handleEvent(.RestoreDidFail)

        XCTAssertEqual(actions, "RRe")
    }

    func testRestorationAfterRestorationFailure() {
        sut.handleEvent(.DidClickRestore)
        sut.handleEvent(.RestoreDidFail)
        sut.handleEvent(.DidClickRestore)
        sut.handleEvent(.DidRestore)

        XCTAssertEqual(actions, "RReRS")
    }
}

extension DefaultProductsViewStateMachineTests: ProductsViewStateMachineTarget {
    func fetchProducts() {
        actions.appendContentsOf("F")
    }

    func restorePurchases() {
        actions.appendContentsOf("R")
    }

    func showProducts() {
        actions.appendContentsOf("Sp")
    }

    func showProductFetchError() {
        actions.appendContentsOf("Fe")
    }

    func purchase() {
        actions.appendContentsOf("P")
    }

    func showThankYou() {
        actions.appendContentsOf("S")
    }

    func showPurchaseError() {
        actions.appendContentsOf("Pe")
    }

    func showRestoreError() {
        actions.appendContentsOf("Re")
    }
}

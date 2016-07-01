//
//  StoreViewStateMachineTests.swift
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
import XCTest

class StoreViewStateMachineTests: XCTestCase, StoreViewStateMachine {
    private var sut: StoreViewStateMachine!
    var state: StoreViewState = StoreViewStateNoProducts()
    private var actions: String!

    override func setUp() {
        super.setUp()
        sut = self
        changeState(StoreViewStateNoProducts())
        actions = ""
    }

    func testNormalPurchase() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        let product = createProduct()
        sut.didStartPurchse(product)
        sut.didPurchase(product)

        XCTAssertEqual(actions, "FSpP123SppS")
    }

    func testNormalRestoration() {
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "RS")
    }

    func testProductFetchFailureAndReload() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartProductFetch()
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "FFeFSp")
    }

    func testRestorationAfterProductFetch() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FSpRS")
    }

    func testRestorationAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FFeRS")
    }

    func testPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchse(createProduct())
        sut.didFailPurchasingProduct(error: "any")

        XCTAssertEqual(actions, "FSpP123SppPe")
    }

    func testPurchaseAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        let product = createProduct()
        sut.didStartPurchse(product)
        sut.didFailPurchasingProduct(error: "any")
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchse(product)
        sut.didPurchase(product)

        XCTAssertEqual(actions, "FSpP123SppPeP123SppS")
    }

    func testRestorationFailure() {
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "RRe")
    }

    func testRestorationAfterRestorationFailure() {
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "RReRS")
    }

    func testRestorationAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchse(createProduct())
        sut.didFailPurchasingProduct(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FSpP123SppPeRS")
    }

    func testShowsThankYouOnViewReloadWhenPurchased() {
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.viewShouldReloadData(StoreViewDummy())

        XCTAssertEqual(actions, "RSS")
    }

    func testProductFetchOnViewReloadAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "FFeFSp")
    }

    func testManualProductsFetch() {
        sut.viewDidStartProductFetch()

        XCTAssertEqual(actions, "F")
    }

    func testDidPurchaseBeforeProductFetch() {
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "S")
    }

    func testDidPurchaseDuringProductFetch() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "FS")
    }

    func testDidPurchaseAfterProductFetch() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "FSpS")
    }

    func testDidPurchaseAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "FFeS")
    }

    func testDidPuchaseDuringRestoration() {
        sut.viewDidStartPurchaseRestoration()
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "RS")
    }

    func testDidPurchaseAfterRestorationFailure() {
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "RReS")
    }
}

extension StoreViewStateMachineTests {
    func changeState(newState: StoreViewState) {
        state = newState
    }

    func fetchProducts() {
        actions.appendContentsOf("F")
    }

    func showProducts(products: [Product]) {
        actions.appendContentsOf("Sp")
    }

    func showProductsFetchError(error: String) {
        actions.appendContentsOf("Fe")
    }

    func purchaseProduct(identifier identifier: String) {
        actions.appendContentsOf("P\(identifier)")
    }

    func showPurchaseProgress() {
        actions.appendContentsOf("Spp")
    }

    func showPurchaseError(error: String) {
        actions.appendContentsOf("Pe")
    }

    func restorePurchases() {
        actions.appendContentsOf("R")
    }
    
    func showPurchaseRestorationError(error: String) {
        actions.appendContentsOf("Re")
    }

    func showThankYou() {
        actions.appendContentsOf("S")
    }
}

private func createPresentationProduct(identifier identifier: String) -> PresentationProduct {
    return PresentationProduct(identifier: identifier, name: "product1", price: "$100")
}

private func createProduct() -> Product {
    return Product(identifier: "123", name: "product1", price: NSDecimalNumber(integer: 100), localizedPrice: "$100")
}

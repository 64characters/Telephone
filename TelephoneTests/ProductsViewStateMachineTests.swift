//
//  ProductsViewStateMachineTests.swift
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

class ProductsViewStateMachineTests: XCTestCase, ProductsViewStateMachine {
    private var sut: ProductsViewStateMachine!
    var state: ProductsViewState = ProductsViewStateNoProducts()
    private var actions: String!

    override func setUp() {
        super.setUp()
        sut = self
        changeState(ProductsViewStateNoProducts())
        actions = ""
    }

    func testNormalPurchase() {
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "FSpP123S")
    }

    func testNormalRestoration() {
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "RS")
    }

    func testProductFetchFailureAndReload() {
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartProductFetch()
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "FFeFSp")
    }

    func testRestorationAfterProductFetch() {
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FSpRS")
    }

    func testRestorationAfterProductFetchFailure() {
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FFeRS")
    }

    func testPurchaseFailure() {
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didFailPurchasingProduct(error: "any")

        XCTAssertEqual(actions, "FSpP123Pe")
    }

    func testPurchaseAfterPurchaseFailure() {
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didFailPurchasingProduct(error: "any")
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didPurchase(createProduct())

        XCTAssertEqual(actions, "FSpP123PeP123S")
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
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didFailPurchasingProduct(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FSpP123PeRS")
    }

    func testShowsThankYouOnViewReloadWhenPurchased() {
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.viewShouldReloadData(ProductsViewDummy())

        XCTAssertEqual(actions, "RSS")
    }

    func testProductFetchOnViewReloadAfterProductFetchFailure() {
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewShouldReloadData(ProductsViewDummy())
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "FFeFSp")
    }

    func testManualProductsFetch() {
        sut.viewDidStartProductFetch()

        XCTAssertEqual(actions, "F")
    }
}

extension ProductsViewStateMachineTests {
    func changeState(newState: ProductsViewState) {
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

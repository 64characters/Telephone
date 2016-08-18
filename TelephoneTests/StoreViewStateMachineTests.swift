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

final class StoreViewStateMachineTests: XCTestCase, StoreViewStateMachine {
    private var sut: StoreViewStateMachine!
    var state: StoreViewState = StoreViewStateNoProducts()
    private var actions: String!

    override func setUp() {
        super.setUp()
        sut = self
        changeState(StoreViewStateNoProducts())
        actions = ""
    }

    // MARK: - Fetch

    func testProductFetchFailureAndReload() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartProductFetch()
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "FFeFSp")
    }

    func testProductFetchOnViewReloadAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "FFeFSp")
    }

    // MARK: - Purchase

    func testNormalPurchase() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()

        XCTAssertEqual(actions, "FSpP123SppTy")
    }

    func testPurchaseFailureWithError() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")

        XCTAssertEqual(actions, "FSpP123SppPe")
    }

    func testPurchaseFailureWithoutError() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts()

        XCTAssertEqual(actions, "FSpP123SppScp")
    }

    func testPurchaseAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()

        XCTAssertEqual(actions, "FSpP123SppPeP123SppTy")
    }

    func testPurchaseAfterRestorationFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()

        XCTAssertEqual(actions, "FSpRScpReP123SppTy")
    }

    // MARK: - Restoration

    func testRestorationAfterProductFetch() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FSpRTy")
    }

    func testRestorationFailureAfterProductFetch() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "FSpRScpRe")
    }

    func testRestorationCancellationAfterProductFetch() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()

        XCTAssertEqual(actions, "FSpRScp")
    }

    func testRestorationAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FFeRTy")
    }

    func testRestorationFailureAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "FFeRScfeRe")
    }

    func testRestorationCancellationAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()

        XCTAssertEqual(actions, "FFeRScfe")
    }

    func testRestorationAfterRestorationFailureAfterProductFetch() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FSpRScpReRTy")
    }

    func testRestorationAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()

        XCTAssertEqual(actions, "FSpP123SppPeRTy")
    }

    // MARK: - Other

    func testShowsThankYouOnViewReloadWhenPurchased() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.viewShouldReloadData(StoreViewDummy())

        XCTAssertEqual(actions, "FSpRTyTy")
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

    func purchaseProduct(withIdentifier identifier: String) {
        actions.appendContentsOf("P\(identifier)")
    }

    func showPurchaseProgress() {
        actions.appendContentsOf("Spp")
    }

    func showPurchaseError(error: String) {
        actions.appendContentsOf("Pe")
    }

    func showCachedProducts() {
        actions.appendContentsOf("Scp")
    }

    func restorePurchases() {
        actions.appendContentsOf("R")
    }
    
    func showCachedProductsAndRestoreError(error: String) {
        actions.appendContentsOf("ScpRe")
    }

    func showCachedFetchErrorAndRestoreError(error: String) {
        actions.appendContentsOf("ScfeRe")
    }

    func showCachedFetchError() {
        actions.appendContentsOf("Scfe")
    }

    func showThankYou() {
        actions.appendContentsOf("Ty")
    }
}

private func createPresentationProduct(identifier identifier: String) -> PresentationProduct {
    return PresentationProduct(identifier: identifier, name: "product1", price: "$100")
}

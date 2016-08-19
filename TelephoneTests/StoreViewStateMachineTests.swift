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

import Foundation
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

    // MARK: - Check before fetch

    func testNormalPurchaseCheck() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpTy")
    }

    func testFetchAfterPurchaseCheckFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "CpFSp")
    }

    func testFetchFailureAfterPurchaseCheckFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")

        XCTAssertEqual(actions, "CpFFe")
    }

    // MARK: - Fetch

    func testProductFetchFailureAndReload() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartProductFetch()
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "CpFFeFSp")
    }

    func testProductFetchOnViewReloadAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])

        XCTAssertEqual(actions, "CpFFeCpFSp")
    }

    // MARK: - Purchase

    func testNormalPurchase() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpP123SppCpTy")
    }

    func testPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")

        XCTAssertEqual(actions, "CpFSpP123SppScpPe")
    }

    func testPurchaseCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didCancelPurchasingProducts()

        XCTAssertEqual(actions, "CpFSpP123SppScp")
    }

    func testPurchaseAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpP123SppScpPeP123SppCpTy")
    }

    func testPurchaseAfterPurchaseCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didCancelPurchasingProducts()
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpP123SppScpP123SppCpTy")
    }

    func testPurchaseAfterRestorationFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpRScpReP123SppCpTy")
    }

    func testPurchaseAfterRestorationCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpRScpP123SppCpTy")
    }

    // MARK: - Restoration

    func testNormalRestoration() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpRCpTy")
    }

    func testRestorationFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "CpFSpRScpRe")
    }

    func testRestorationCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()

        XCTAssertEqual(actions, "CpFSpRScp")
    }

    func testRestorationAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFFeRCpTy")
    }

    func testRestorationFailureAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "CpFFeRScfeRe")
    }

    func testRestorationCancellationAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()

        XCTAssertEqual(actions, "CpFFeRScfe")
    }

    func testRestorationAfterRestorationFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpRScpReRCpTy")
    }

    func testRestorationAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidMakePurchase(createPresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpP123SppScpPeRCpTy")
    }

    // MARK: - Other

    func testShowsThankYouOnViewReloadWhenPurchased() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetchProducts([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: NSDate.distantFuture())
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didCheckPurchase(expiration: NSDate.distantFuture())

        XCTAssertEqual(actions, "CpFSpRCpTyCpTy")
    }
}

extension StoreViewStateMachineTests {
    func changeState(newState: StoreViewState) {
        state = newState
    }

    func checkPurchase() {
        actions.appendContentsOf("Cp")
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

    func showCachedProductsAndPurchaseError(error: String) {
        actions.appendContentsOf("ScpPe")
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

    func showThankYou(expiration expiration: NSDate) {
        actions.appendContentsOf("Ty")
    }
}

private func createPresentationProduct(identifier identifier: String) -> PresentationProduct {
    return PresentationProduct(identifier: identifier, name: "product1", price: "$100")
}

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
    fileprivate var actions: String!

    override func setUp() {
        super.setUp()
        sut = self
        changeState(StoreViewStateNoProducts())
        actions = ""
    }

    // MARK: - Check before fetch

    func testNormalPurchaseCheck() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpTy")
    }

    func testFetchAfterPurchaseCheckFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])

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
        sut.didFetch([])

        XCTAssertEqual(actions, "CpFFeFSp")
    }

    func testProductFetchOnViewReloadAfterProductFetchFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])

        XCTAssertEqual(actions, "CpFFeCpFSp")
    }

    // MARK: - Purchase

    func testNormalPurchase() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppCpTy")
    }

    func testPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")

        XCTAssertEqual(actions, "CpFSpP123SppScpPe")
    }

    func testPurchaseCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didCancelPurchasingProducts()

        XCTAssertEqual(actions, "CpFSpP123SppScp")
    }

    func testPurchaseAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppScpPeP123SppCpTy")
    }

    func testPurchaseAfterPurchaseCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didCancelPurchasingProducts()
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppScpP123SppCpTy")
    }

    func testPurchaseAfterRestorationFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRScpReP123SppCpTy")
    }

    func testPurchaseAfterRestorationCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didPurchaseProducts()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRScpP123SppCpTy")
    }

    // MARK: - Restoration

    func testNormalRestoration() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRCpTy")
    }

    func testRestorationFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "CpFSpRScpRe")
    }

    func testRestorationCancellation() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
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
        sut.didCheckPurchase(expiration: Date.distantFuture)

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
        sut.didFetch([])
        sut.viewDidStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRScpReRCpTy")
    }

    func testRestorationAfterPurchaseFailure() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidMakePurchase(product: makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasingProducts(error: "any")
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppScpPeRCpTy")
    }

    // MARK: - Other

    func testShowsThankYouOnViewReloadWhenPurchased() {
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.viewDidStartPurchaseRestoration()
        sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)
        sut.viewShouldReloadData(StoreViewDummy())
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRCpTyCpTy")
    }
}

extension StoreViewStateMachineTests {
    func changeState(_ newState: StoreViewState) {
        state = newState
    }

    func checkPurchase() {
        actions.append("Cp")
    }

    func fetchProducts() {
        actions.append("F")
    }

    func show(_ products: [Product]) {
        actions.append("Sp")
    }

    func showProductsFetchError(_ error: String) {
        actions.append("Fe")
    }

    func purchaseProduct(withIdentifier identifier: String) {
        actions.append("P\(identifier)")
    }

    func showPurchaseProgress() {
        actions.append("Spp")
    }

    func showCachedProductsAndPurchaseError(_ error: String) {
        actions.append("ScpPe")
    }

    func showCachedProducts() {
        actions.append("Scp")
    }

    func restorePurchases() {
        actions.append("R")
    }
    
    func showCachedProductsAndRestoreError(_ error: String) {
        actions.append("ScpRe")
    }

    func showCachedFetchErrorAndRestoreError(_ error: String) {
        actions.append("ScfeRe")
    }

    func showCachedFetchError() {
        actions.append("Scfe")
    }

    func showThankYou(expiration: Date) {
        actions.append("Ty")
    }
}

private func makePresentationProduct(identifier: String) -> PresentationProduct {
    return PresentationProduct(identifier: identifier, name: "product1", price: "$100")
}

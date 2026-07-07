//
//  StoreViewStateMachineTests.swift
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

import Foundation
import UseCases
import XCTest

final class StoreViewStateMachineTests: XCTestCase, @preconcurrency StoreViewStateMachine {
    private var sut: StoreViewStateMachine!
    var state: StoreViewState = StoreViewStateNoProducts()
    private var actions: String!

    override func setUp() async throws {
        sut = self
        changeState(StoreViewStateNoProducts())
        actions = ""
    }

    // MARK: - Check before fetch

    func testNormalPurchaseCheck() async {
        await sut.shouldReloadData()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpTy")
    }

    func testFetchAfterPurchaseCheckFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])

        XCTAssertEqual(actions, "CpFSp")
    }

    func testFetchFailureAfterPurchaseCheckFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")

        XCTAssertEqual(actions, "CpFFe")
    }

    // MARK: - Fetch

    func testProductFetchFailureAndReload() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.didStartProductFetch()
        sut.didFetch([])

        XCTAssertEqual(actions, "CpFFeFSp")
    }

    func testProductFetchOnViewReloadAfterProductFetchFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])

        XCTAssertEqual(actions, "CpFFeCpFSp")
    }

    // MARK: - Purchase

    func testNormalPurchase() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        await sut.didPurchase()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppCpTy")
    }

    func testPurchaseFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasing(error: "any")

        XCTAssertEqual(actions, "CpFSpP123SppScpPe")
    }

    func testPurchaseCancellation() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didCancelPurchasing()

        XCTAssertEqual(actions, "CpFSpP123SppScp")
    }

    func testPurchaseAfterPurchaseFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasing(error: "any")
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        await sut.didPurchase()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppScpPeP123SppCpTy")
    }

    func testPurchaseAfterPurchaseCancellation() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didCancelPurchasing()
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        await sut.didPurchase()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppScpP123SppCpTy")
    }

    func testPurchaseAfterRestorationFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        await sut.didPurchase()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRScpReP123SppCpTy")
    }

    func testPurchaseAfterRestorationCancellation() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        await sut.didPurchase()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRScpP123SppCpTy")
    }

    // MARK: - Restoration

    func testNormalRestoration() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchaseRestoration()
        await sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRCpTy")
    }

    func testRestorationFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "CpFSpRScpRe")
    }

    func testRestorationCancellation() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()

        XCTAssertEqual(actions, "CpFSpRScp")
    }

    func testRestorationAfterProductFetchFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.didStartPurchaseRestoration()
        await sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFFeRCpTy")
    }

    func testRestorationFailureAfterProductFetchFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.didStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")

        XCTAssertEqual(actions, "CpFFeRScfeRe")
    }

    func testRestorationCancellationAfterProductFetchFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.didStartPurchaseRestoration()
        sut.didCancelRestoringPurchases()

        XCTAssertEqual(actions, "CpFFeRScfe")
    }

    func testRestorationAfterRestorationFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchaseRestoration()
        sut.didFailRestoringPurchases(error: "any")
        sut.didStartPurchaseRestoration()
        await sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpRScpReRCpTy")
    }

    func testRestorationAfterPurchaseFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        sut.didFailPurchasing(error: "any")
        sut.didStartPurchaseRestoration()
        await sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppScpPeRCpTy")
    }

    func testRestorationDuringPurchase() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchasing(makePresentationProduct(identifier: "123"))
        sut.didStartPurchasingProduct(withIdentifier: "123")
        await sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)

        XCTAssertEqual(actions, "CpFSpP123SppCpTy")
    }

    // MARK: - Receipt refresh

    func testReceiptRefreshAfterProductFetch() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartReceiptRefresh()

        XCTAssertEqual(actions, "CpFSpRr")
    }

    func testReceiptRefreshAfterProductFetchFailure() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFailFetchingProducts(error: "any")
        sut.didStartReceiptRefresh()

        XCTAssertEqual(actions, "CpFFeRr")
    }

    // MARK: - Other

    func testShowsThankYouOnViewReloadWhenPurchased() async {
        await sut.shouldReloadData()
        sut.didFailCheckingPurchase()
        sut.didFetch([])
        sut.didStartPurchaseRestoration()
        await sut.didRestorePurchases()
        sut.didCheckPurchase(expiration: Date.distantFuture)
        await sut.shouldReloadData()
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

    func refreshReceipt() {
        actions.append("Rr")
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

//
//  StoreViewStateMachine.swift
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

protocol StoreViewStateMachine: PurchaseCheckUseCaseOutput, StoreViewEventTarget, ProductsFetchUseCaseOutput, StoreEventTarget {
    var state: StoreViewState { get }
    func changeState(_ newState: StoreViewState)

    func checkPurchase()
    func fetchProducts()
    func show(_ products: [Product])
    func showProductsFetchError(_ error: String)
    func purchaseProduct(withIdentifier identifier: String)
    func showPurchaseProgress()
    func showCachedProductsAndPurchaseError(_ error: String)
    func showCachedProducts()
    func restorePurchases()
    func refreshReceipt()
    func showCachedProductsAndRestoreError(_ error: String)
    func showCachedFetchErrorAndRestoreError(_ error: String)
    func showCachedFetchError()
    func showThankYou(expiration: Date)
}

// PurchaseCheckUseCaseOutput
extension StoreViewStateMachine {
    func didCheckPurchase(expiration: Date) {
        state.didCheckPurchase(expiration: expiration, machine: self)
    }

    func didFailCheckingPurchase() {
        state.didFailCheckingPurchase(machine: self)
    }
}

// StoreViewEventTarget
extension StoreViewStateMachine {
    func shouldReloadData() {
        state.shouldReloadData(machine: self)
    }

    func didStartProductFetch() {
        state.didStartProductFetch(machine: self)
    }

    func didStartPurchasing(_ product: PresentationProduct) {
        state.viewDidStartPurchasing(product, machine: self)
    }

    func didStartPurchaseRestoration() {
        state.didStartPurchaseRestoration(machine: self)
    }

    func didStartReceiptRefresh() {
        state.didStartReceiptRefresh(machine: self)
    }
}

// ProductsFetchUseCaseOutput
extension StoreViewStateMachine {
    func didFetch(_ products: [Product]) {
        state.didFetch(products, machine: self)
    }

    func didFailFetchingProducts(error: String) {
        state.didFailFetchingProducts(error: error, machine: self)
    }
}

// StoreEventTarget
extension StoreViewStateMachine {
    func didStartPurchasingProduct(withIdentifier identifier: String) {
        state.didStartPurchasing(machine: self)
    }

    func didPurchase() {
        state.didPurchase(machine: self)
    }

    func didFailPurchasing(error: String) {
        state.didFailPurchasing(error: error, machine: self)
    }

    func didCancelPurchasing() {
        state.didCancelPurchasing(machine: self)
    }

    func didRestorePurchases() {
        state.didRestorePurchases(machine: self)
    }

    func didFailRestoringPurchases(error: String) {
        state.didFailRestoringPurchases(error: error, machine: self)
    }

    func didCancelRestoringPurchases() {
        state.didCancelRestoringPurchases(machine: self)
    }
}

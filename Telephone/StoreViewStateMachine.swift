//
//  StoreViewStateMachine.swift
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
        state.didCheckPurchase(machine: self, expiration: expiration)
    }

    func didFailCheckingPurchase() {
        state.didFailCheckingPurchase(machine: self)
    }
}

// StoreViewEventTarget
extension StoreViewStateMachine {
    func shouldReloadData() {
        state.viewShouldReloadData(machine: self)
    }

    func didStartProductFetch() {
        state.viewDidStartProductFetch(machine: self)
    }

    func didStartPurchasing(_ product: PresentationProduct) {
        state.viewDidMakePurchase(machine: self, product: product)
    }

    func didStartPurchaseRestoration() {
        state.viewDidStartPurchaseRestoration(machine: self)
    }

    func didStartReceiptRefresh() {
        state.viewDidStartReceiptRefresh(machine: self)
    }
}

// ProductsFetchUseCaseOutput
extension StoreViewStateMachine {
    func didFetch(_ products: [Product]) {
        state.didFetchProducts(machine: self, products: products)
    }

    func didFailFetchingProducts(error: String) {
        state.didFailFetchingProducts(machine: self, error: error)
    }
}

// StoreEventTarget
extension StoreViewStateMachine {
    func didStartPurchasingProduct(withIdentifier identifier: String) {
        state.didStartPurchasingProduct(machine: self, identifier: identifier)
    }

    func didPurchaseProducts() {
        state.didPurchaseProducts(machine: self)
    }

    func didFailPurchasingProducts(error: String) {
        state.didFailPurchasingProducts(machine: self, error: error)
    }

    func didCancelPurchasingProducts() {
        state.didCancelPurchasingProducts(machine: self)
    }

    func didRestorePurchases() {
        state.didRestorePurchases(machine: self)
    }

    func didFailRestoringPurchases(error: String) {
        state.didFailRestoringPurchases(machine: self, error: error)
    }

    func didCancelRestoringPurchases() {
        state.didCancelRestoringPurchases(machine: self)
    }
}

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

protocol StoreViewStateMachine: StoreViewEventTarget, ProductsFetchUseCaseOutput,
ProductPurchaseEventTarget, PurchaseRestorationUseCaseOutput {
    var state: StoreViewState { get }
    func changeState(newState: StoreViewState)

    func fetchProducts()
    func showProducts(products: [Product])
    func showProductsFetchError(error: String)
    func purchaseProduct(withIdentifier identifier: String)
    func showPurchaseProgress()
    func showPurchaseError(error: String)
    func showCachedProducts()
    func restorePurchases()
    func showPurchaseRestorationError(error: String)
    func showThankYou()
}

extension StoreViewStateMachine {
    func viewShouldReloadData(view: StoreView) {
        state.viewShouldReloadData(machine: self)
    }

    func viewDidStartProductFetch() {
        state.viewDidStartProductFetch(machine: self)
    }

    func viewDidMakePurchase(product: PresentationProduct) {
        state.viewDidMakePurchase(machine: self, product: product)
    }

    func viewDidStartPurchaseRestoration() {
        state.viewDidStartPurchaseRestoration(machine: self)
    }
}

extension StoreViewStateMachine {
    func didFetchProducts(products: [Product]) {
        state.didFetchProducts(machine: self, products: products)
    }

    func didFailFetchingProducts(error error: String) {
        state.didFailFetchingProducts(machine: self, error: error)
    }
}

extension StoreViewStateMachine {
    func didStartPurchasingProduct(withIdentifier identifier: String) {
        state.didStartPurchasingProduct(machine: self, identifier: identifier)
    }

    func didPurchaseProducts() {
        state.didPurchaseProducts(machine: self)
    }

    func didFailPurchasingProducts(error error: String) {
        state.didFailPurchasingProducts(machine: self, error: error)
    }

    func didFailPurchasingProducts() {
        state.didFailPurchasingProducts(machine: self)
    }
}

extension StoreViewStateMachine {
    func didRestorePurchases() {
        state.didRestorePurchases(machine: self)
    }

    func didFailRestoringPurchases(error error: String) {
        state.didFailRestoringPurchases(machine: self, error: error)
    }
}

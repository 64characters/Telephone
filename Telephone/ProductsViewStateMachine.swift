//
//  ProductsViewStateMachine.swift
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

protocol ProductsViewStateMachine: ProductsViewEventTarget, ProductsFetchInteractorOutput,
ProductPurchaseInteractorOutput, PurchaseRestorationInteractorOutput {
    var state: ProductsViewState { get }
    func changeState(newState: ProductsViewState)

    func fetchProducts()
    func showProducts(products: [Product])
    func showProductsFetchError(error: String)
    func purchaseProduct(identifier identifier: String)
    func showPurchaseError(error: String)
    func restorePurchases()
    func showPurchaseRestorationError(error: String)
    func showThankYou()
}

extension ProductsViewStateMachine {
    func viewShouldReloadData(view: ProductsView) {
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

extension ProductsViewStateMachine {
    func didFetchProducts(products: [Product]) {
        state.didFetchProducts(machine: self, products: products)
    }

    func didFailFetchingProducts(error error: String) {
        state.didFailFetchingProducts(machine: self, error: error)
    }
}

extension ProductsViewStateMachine {
    func didPurchase(product: Product) {
        state.didPurchase(machine: self, product: product)
    }

    func didFailPurchasingProduct(error error: String) {
        state.didFailPurchasingProduct(machine: self, error: error)
    }
}

extension ProductsViewStateMachine {
    func didRestorePurchases() {
        state.didRestorePurchases(machine: self)
    }

    func didFailRestoringPurchases(error error: String) {
        state.didFailRestoringPurchases(machine: self, error: error)
    }
}

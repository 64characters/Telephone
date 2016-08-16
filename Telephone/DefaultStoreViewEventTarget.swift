//
//  DefaultStoreViewEventTarget.swift
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

final class DefaultStoreViewEventTarget {
    private(set) var state: StoreViewState = StoreViewStateNoProducts()
    private var products: [Product] = []

    private let factory: StoreUseCaseFactory
    private var restoration: UseCase
    private let presenter: StoreViewPresenter

    init(factory: StoreUseCaseFactory, purchaseRestoration: UseCase, presenter: StoreViewPresenter) {
        self.factory = factory
        self.restoration = purchaseRestoration
        self.presenter = presenter
    }
}

extension DefaultStoreViewEventTarget: StoreViewStateMachine {
    func changeState(newState: StoreViewState) {
        state = newState
    }

    func fetchProducts() {
        factory.createProductsFetchUseCase(output: self).execute()
        presenter.showProductsFetchProgress()
    }

    func showProducts(products: [Product]) {
        self.products = products
        presenter.showProducts(products)
    }

    func showProductsFetchError(error: String) {
        presenter.showProductsFetchError(error)
    }

    func purchaseProduct(withIdentifier identifier: String) {
        do {
            try factory.createProductPurchaseUseCase(identifier: identifier).execute()
        } catch {
            print("Could not make purchase: \(error)")
        }
    }

    func showPurchaseProgress() {
        presenter.showPurchaseProgress()
    }

    func showPurchaseError(error: String) {
        showCachedProducts()
        presenter.showPurchaseError(error)
    }

    func showCachedProducts() {
        presenter.showProducts(products)
    }

    func restorePurchases() {
        restoration.execute()
        presenter.showPurchaseRestorationProgress()
    }

    func showPurchaseRestorationError(error: String) {
        showCachedProducts()
        presenter.showPurchaseRestorationError(error)
    }

    func showThankYou() {

    }
}

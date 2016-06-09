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

class DefaultStoreViewEventTarget {
    private let interactorFactory: StoreInteractorFactory
    private let presenterFactory: StorePresenterFactory

    private(set) var state: StoreViewState = StoreViewStateNoProducts()

    init(interactorFactory: StoreInteractorFactory, presenterFactory: StorePresenterFactory) {
        self.interactorFactory = interactorFactory
        self.presenterFactory = presenterFactory
    }
}

extension DefaultStoreViewEventTarget: StoreViewStateMachine {
    func changeState(newState: StoreViewState) {
        state = newState
    }

    func fetchProducts() {
        interactorFactory.createProductsFetchInteractor(output: self).execute()
        presenterFactory.createStoreViewPresenter().showProductsFetchProgress()
    }

    func showProducts(products: [Product]) {
        presenterFactory.createStoreViewPresenter().showProducts(products)
    }

    func showProductsFetchError(error: String) {
        presenterFactory.createStoreViewPresenter().showProductsFetchError(error)
    }

    func purchaseProduct(identifier identifier: String) {}
    func showPurchaseError(error: String) {}
    func restorePurchases() {}
    func showPurchaseRestorationError(error: String) {}
    func showThankYou() {}
}

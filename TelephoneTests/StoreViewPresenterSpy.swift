//
//  StoreViewPresenterSpy.swift
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

final class StoreViewPresenterSpy {
    private(set) var showProductsCallCount = 0
    private(set) var invokedProducts: [Product] = []
    private(set) var invokedProductsFetchError = ""
    private(set) var didCallShowProductsFetchProgress = false
    private(set) var didCallShowPurchaseProgress = false
    private(set) var invokedPurchaseError = ""
}

extension StoreViewPresenterSpy: StoreViewPresenter {
    func showProducts(products: [Product]) {
        showProductsCallCount += 1
        invokedProducts = products
    }

    func showProductsFetchError(error: String) {
        invokedProductsFetchError = error
    }

    func showProductsFetchProgress() {
        didCallShowProductsFetchProgress = true
    }

    func showPurchaseProgress() {
        didCallShowPurchaseProgress = true
    }

    func showPurchaseError(error: String) {
        invokedPurchaseError = error
    }
}

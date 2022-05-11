//
//  StoreViewPresenterSpy.swift
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

final class StoreViewPresenterSpy {
    private(set) var didCallShowPurchaseCheckProgress = false

    private(set) var showProductsCallCount = 0
    private(set) var invokedProducts: [Product] = []

    private(set) var showProductsFetchErrorCallCount = 0
    private(set) var invokedProductsFetchError = ""
    private(set) var didCallShowProductsFetchProgress = false

    private(set) var didCallShowPurchaseProgress = false
    private(set) var invokedPurchaseError = ""

    private(set) var didCallShowPurchaseRestorationProgress = false
    private(set) var invokedPurchaseRestorationError = ""

    private(set) var didCallShowPurchased = false
    private(set) var invokedDate = Date.distantPast
}

extension StoreViewPresenterSpy: StoreViewPresenter {
    func showPurchaseCheckProgress() {
        didCallShowPurchaseCheckProgress = true
    }

    func show(_ products: [Product]) {
        showProductsCallCount += 1
        invokedProducts = products
    }

    func showProductsFetchError(_ error: String) {
        showProductsFetchErrorCallCount += 1
        invokedProductsFetchError = error
    }

    func showProductsFetchProgress() {
        didCallShowProductsFetchProgress = true
    }

    func showPurchaseProgress() {
        didCallShowPurchaseProgress = true
    }

    func showPurchaseError(_ error: String) {
        invokedPurchaseError = error
    }

    func showPurchaseRestorationProgress() {
        didCallShowPurchaseRestorationProgress = true
    }

    func showPurchaseRestorationError(_ error: String) {
        invokedPurchaseRestorationError = error
    }

    func showPurchased(until date: Date) {
        didCallShowPurchased = true
        invokedDate = date
    }
}

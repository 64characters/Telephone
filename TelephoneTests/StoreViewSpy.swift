//
//  StoreViewSpy.swift
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

class StoreViewSpy {
    private(set) var invokedProducts: [PresentationProduct] = []
    private(set) var invokedError = ""
    private(set) var didCallShowProductsFetchProgress = false
    private(set) var didCallDisablePurchaseRestoration = false
    private(set) var didCallEnablePurchaseRestoration = false
}

extension StoreViewSpy: StoreView {}

extension StoreViewSpy: ProductsFetchPresenterOutput {
    func showProducts(products: [PresentationProduct]) {
        invokedProducts = products
    }

    func showProductsFetchError(error: String) {
        invokedError = error
    }

    func showProductsFetchProgress() {
        didCallShowProductsFetchProgress = true
    }

    func disablePurchaseRestoration() {
        didCallDisablePurchaseRestoration = true
    }

    func enablePurchaseRestoration() {
        didCallEnablePurchaseRestoration = true
    }
}

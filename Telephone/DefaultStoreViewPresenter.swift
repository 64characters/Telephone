//
//  DefaultStoreViewPresenter.swift
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

final class DefaultStoreViewPresenter {
    private let output: StoreViewPresenterOutput

    init(output: StoreViewPresenterOutput) {
        self.output = output
    }
}

extension DefaultStoreViewPresenter: StoreViewPresenter {
    func showPurchaseCheckProgress() {
        output.showPurchaseCheckProgress()
        output.disablePurchaseRestoration()
    }

    func show(_ products: [Product]) {
        output.show(products.sorted().map(PresentationProduct.init))
        output.enablePurchaseRestoration()
    }

    func showProductsFetchError(_ error: String) {
        output.showProductsFetchError(productsFetchError(error: error))
        output.enablePurchaseRestoration()
    }

    func showProductsFetchProgress() {
        output.showProductsFetchProgress()
        output.disablePurchaseRestoration()
    }

    func showPurchaseProgress() {
        output.showPurchaseProgress()
        output.disablePurchaseRestoration()
    }

    func showPurchaseError(_ error: String) {
        output.showPurchaseError(error)
        output.enablePurchaseRestoration()
    }

    func showPurchaseRestorationProgress() {
        output.showPurchaseRestorationProgress()
        output.disablePurchaseRestoration()
    }

    func showPurchaseRestorationError(_ error: String) {
        output.showPurchaseRestorationError(error)
        output.enablePurchaseRestoration()
    }

    func showPurchased(until date: Date) {
        output.showPurchased(until: date)
        output.showSubscriptionManagement()
    }
}

private func productsFetchError(error: String) -> String {
    let prefix = NSLocalizedString(
        "Could not fetch products.", comment: "Products fetch error."
    )
    return "\(prefix) \(error)"
}

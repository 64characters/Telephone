//
//  StoreViewPresenter.swift
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

protocol StoreViewPresenter {
    func showPurchaseCheckProgress()

    func show(_ products: [Product])
    func showProductsFetchError(_ error: String)
    func showProductsFetchProgress()

    func showPurchaseProgress()
    func showPurchaseError(_ error: String)

    func showPurchaseRestorationProgress()
    func showPurchaseRestorationError(_ error: String)

    func showPurchased(until date: Date)
}

protocol StoreViewPresenterOutput {
    func showPurchaseCheckProgress()

    func show(_ products: [PresentationProduct])
    func showProductsFetchError(_ error: String)
    func showProductsFetchProgress()

    func showPurchaseProgress()
    func showPurchaseError(_ error: String)

    func showPurchaseRestorationProgress()
    func showPurchaseRestorationError(_ error: String)

    func disablePurchaseRestoration()
    func enablePurchaseRestoration()

    func showPurchased(until date: Date)
    func showSubscriptionManagement()
}

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

protocol ProductsViewStateMachine {
    func handleEvent(event: ProductsViewStateMachineEvent)
}

protocol ProductsViewStateMachineTarget {
    func fetchProducts()
    func restorePurchases()
    func showProducts()
    func showProductFetchError()
    func purchase()
    func showThankYou()
    func showPurchaseError()
    func showRestoreError()
}

enum ProductsViewStateMachineEvent {
    case ViewShouldReload
    case DidClickReload
    case DidClickRestore
    case DidFetch
    case FetchDidFail
    case DidClickPurchase
    case DidPurchase
    case PurchaseDidFail
    case DidRestore
    case RestoreDidFail
}

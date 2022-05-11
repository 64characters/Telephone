//
//  StoreViewState.swift
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

// Given State              Event                           Next State               Action
// ---------------------------------------------------------------------------------------------------------------------
// NoProducts               ShouldReloadData            Checking                 CheckPurchase
//
// Checking                 DidCheckPurchase            Purchased                ShowThankYou
// Checking                 DidFailCheckingPurchase     Fetching                 FetchProducts
// CheckingAfterFetch       DidCheckPurchase            Purchased                ShowThankYou
// CheckingAfterFetch       DidFailCheckingPurchase     Fetched                  ShowCachedProducts
//
// Fetching                 DidFetchProducts            Fetched                  ShowProducts
// Fetching                 DidFailFetchingProducts     FetchError               ShowProductsFetchError
// Fetched                  ViewDidStartPurchasing      Fetched                  PurchaseProduct
// Fetched                  DidStartPurchasing          Purchasing               ShowPurchaseProgress
// Fetched                  DidStartPurchaseRestoration Restoring                RestorePurchases
// Fetched                  DidStartReceiptRefresh      Refreshing               RefreshReceipt
// FetchError               ShouldReloadData            Checking                 CheckPurchase
// FetchError               DidStartProductFetch        Fetching                 FetchProducts
// FetchError               DidStartPurchaseRestoration RestoringAfterFetchError RestorePurchases
// FetchError               DidStartReceiptRefresh      Refreshing               RefreshReceipt
//
// Purchasing               DidPurchase                 CheckingAfterFetch       CheckPurchase
// Purchasing               DidFailPurchasing           Fetched                  ShowCachedProductsAndPurchaseError
// Purchasing               DidCancelPurchasing         Fetched                  ShowCachedProducts
// Purchasing               DidRestorePurchases         CheckingAfterFetch       CheckPurchase
// Purchased                ShouldReloadData            Checking                 CheckPurchase
//
// Restoring                DidRestorePurchases         CheckingAfterFetch       CheckPurchase
// Restoring                DidFailRestoringPurchases   Fetched                  ShowCachedProductsAndRestoreError
// Restoring                DidCancelRestoringPurchases Fetched                  ShowCachedProducts
// RestoringAfterFetchError DidRestorePurchases         Checking                 CheckPurchase
// RestoringAfterFetchError DidFailRestoringPurchases   FetchError               ShowCachedFetchErrorAndRestoreError
// RestoringAfterFetchError DidCancelRestoringPurchases FetchError               ShowCachedFetchError
//
// Refreshing               N/A                             N/A                      N/A


import UseCases

class StoreViewState {
    func shouldReloadData(machine: StoreViewStateMachine) {
        print("\(#function) is not supported for \(self)")
    }

    func didCheckPurchase(expiration: Date, machine: StoreViewStateMachine) {
        print("\(#function) is not supported for \(self)")
    }

    func didFailCheckingPurchase(machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didStartProductFetch(machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFetch(_ products: [Product], machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailFetchingProducts(error: String, machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func viewDidStartPurchasing(_ product: PresentationProduct, machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didStartPurchasing(machine: StoreViewStateMachine) {
        print("\(#function) is not supported for \(self)")
    }

    func didPurchase(machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailPurchasing(error: String, machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didCancelPurchasing(machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didStartPurchaseRestoration(machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didStartReceiptRefresh(machine: StoreViewStateMachine) {
        print("\(#function) is not supported for \(self)")
    }

    func didRestorePurchases(machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailRestoringPurchases(error: String, machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didCancelRestoringPurchases(machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }
}

final class StoreViewStateNoProducts: StoreViewState {
    override func shouldReloadData(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateChecking())
        machine.checkPurchase()
    }
}

class StoreViewStateChecking: StoreViewState {
    override func didCheckPurchase(expiration: Date, machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou(expiration: expiration)
    }

    override func didFailCheckingPurchase(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetching())
        machine.fetchProducts()
    }
}

final class StoreViewStateCheckingAfterFetch: StoreViewStateChecking {}

final class StoreViewStateFetching: StoreViewState {
    override func didFetch(_ products: [Product], machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetched())
        machine.show(products)
    }

    override func didFailFetchingProducts(error: String, machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetchError())
        machine.showProductsFetchError(error)
    }
}

final class StoreViewStateFetched: StoreViewState {
    override func viewDidStartPurchasing(_ product: PresentationProduct, machine: StoreViewStateMachine) {
        machine.purchaseProduct(withIdentifier: product.identifier)
    }

    override func didStartPurchasing(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStatePurchasing())
        machine.showPurchaseProgress()
    }

    override func didStartPurchaseRestoration(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRestoring())
        machine.restorePurchases()
    }

    override func didStartReceiptRefresh(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRefreshing())
        machine.refreshReceipt()
    }
}

final class StoreViewStateFetchError: StoreViewState {
    override func shouldReloadData(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateChecking())
        machine.checkPurchase()
    }

    override func didStartProductFetch(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetching())
        machine.fetchProducts()
    }

    override func didStartPurchaseRestoration(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRestoringAfterFetchError())
        machine.restorePurchases()
    }

    override func didStartReceiptRefresh(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRefreshing())
        machine.refreshReceipt()
    }
}

final class StoreViewStatePurchasing: StoreViewState {
    override func didPurchase(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateCheckingAfterFetch())
        machine.checkPurchase()
    }

    override func didFailPurchasing(error: String, machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetched())
        machine.showCachedProductsAndPurchaseError(error)
    }

    override func didCancelPurchasing(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetched())
        machine.showCachedProducts()
    }

    override func didRestorePurchases(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateCheckingAfterFetch())
        machine.checkPurchase()
    }
}

final class StoreViewStatePurchased: StoreViewState {
    override func shouldReloadData(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateChecking())
        machine.checkPurchase()
    }
}

final class StoreViewStateRestoring: StoreViewState {
    override func didRestorePurchases(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateCheckingAfterFetch())
        machine.checkPurchase()
    }

    override func didFailRestoringPurchases(error: String, machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetched())
        machine.showCachedProductsAndRestoreError(error)
    }

    override func didCancelRestoringPurchases(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetched())
        machine.showCachedProducts()
    }
}

final class StoreViewStateRestoringAfterFetchError: StoreViewState {
    override func didRestorePurchases(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateChecking())
        machine.checkPurchase()
    }

    override func didFailRestoringPurchases(error: String, machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetchError())
        machine.showCachedFetchErrorAndRestoreError(error)
    }

    override func didCancelRestoringPurchases(machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetchError())
        machine.showCachedFetchError()
    }
}

final class StoreViewStateRefreshing: StoreViewState {}

//
//  StoreViewState.swift
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

// Given State     Event                           Next State      Action
// -----------------------------------------------------------------------------
// NoProducts      ViewShouldReloadData            Fetching        FetchProducts
// NoProducts      ViewDidStartProductFetch        Fetching        FetchProducts
// NoProducts      DidPurchase                     Purchased       ShowThankYou
// NoProducts      ViewDidStartPurchaseRestoration Restoring       RestorePurchases
//
// Fetching        DidFetchProducts                Fetched         ShowProducts
// Fetching        DidFailFetchingProducts         FetchError      ShowProductsFetchError
// Fetching        DidPurchase                     Purchased       ShowThankYou
// Fetched         ViewDidMakePurchase             Fetched         PurchaseProduct
// Fetched         DidStartPurchase                Purchasing      ShowPurchaseProgress
// Fetched         DidPurchase                     Purchased       ShowThankYou
// Fetched         ViewDidStartPurchaseRestoration Restoring       RestorePurchasesViewDid
// FetchError      ViewShouldReloadData            Fetching        FetchProducts
// FetchError      ViewDidStartProductFetch        Fetching        FetchProducts
// FetchError      ViewDidStartPurchaseRestoration Restoring       RestorePurchases
// FetchError      DidPurchase                     Purchased       ShowThankYou
//
// Purchasing      DidPurchase                     Purchased       ShowThankYou
// Purchasing      DidFailPurchasingProduct        PurchaseError   ShowPurchaseError
// Purchased       ViewShouldReloadData            Purchased       ShowThankYou
// PurchaseError   ViewDidMakePurchase             PurchaseError   PurchaseProduct
// PurchaseError   DidStartPurchase                Purchasing      ShowPurchaseProgress
// PurchaseError   ViewDidStartPurchaseRestoration Restoring       RestorePurchases
//
// Restoring       DidPurchase                     Purchased       ShowThankYou
// Restoring       DidRestorePurchases             Purchased       ShowThankYou
// Restoring       DidFailRestoringPurchases       RestoreError    ShowRestoreError
// RestoreError    DidPurchase                     Purchased       ShowThankYou
// RestoreError    ViewDidStartPurchaseRestoration Restoring       RestorePurchases


class StoreViewState {
    func viewShouldReloadData(machine machine: StoreViewStateMachine) {
        print("\(#function) is not supported for \(self)")
    }

    func viewDidStartProductFetch(machine machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFetchProducts(machine machine: StoreViewStateMachine, products: [Product])  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailFetchingProducts(machine machine: StoreViewStateMachine, error: String)  {
        print("\(#function) is not supported for \(self)")
    }

    func viewDidMakePurchase(machine machine: StoreViewStateMachine, product: PresentationProduct)  {
        print("\(#function) is not supported for \(self)")
    }

    func didStartPurchase(machine machine: StoreViewStateMachine, product: Product) {
        print("\(#function) is not supported for \(self)")
    }

    func didPurchase(machine machine: StoreViewStateMachine, product: Product)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailPurchasingProduct(machine machine: StoreViewStateMachine, error: String)  {
        print("\(#function) is not supported for \(self)")
    }

    func viewDidStartPurchaseRestoration(machine machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didRestorePurchases(machine machine: StoreViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailRestoringPurchases(machine machine: StoreViewStateMachine, error: String)  {
        print("\(#function) is not supported for \(self)")
    }
}

class StoreViewStateNoProducts: StoreViewState {
    override func viewShouldReloadData(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetching())
        machine.fetchProducts()
    }

    override func viewDidStartProductFetch(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetching())
        machine.fetchProducts()
    }

    override func didPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }

    override func viewDidStartPurchaseRestoration(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class StoreViewStateFetching: StoreViewState {
    override func didFetchProducts(machine machine: StoreViewStateMachine, products: [Product]) {
        machine.changeState(StoreViewStateFetched())
        machine.showProducts(products)
    }

    override func didFailFetchingProducts(machine machine: StoreViewStateMachine, error: String) {
        machine.changeState(StoreViewStateFetchError())
        machine.showProductsFetchError(error)
    }

    override func didPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }
}

class StoreViewStateFetched: StoreViewState {
    override func viewDidMakePurchase(machine machine: StoreViewStateMachine, product: PresentationProduct) {
        machine.purchaseProduct(identifier: product.identifier)
    }

    override func didStartPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchasing())
        machine.showPurchaseProgress()
    }

    override func didPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }

    override func viewDidStartPurchaseRestoration(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class StoreViewStateFetchError: StoreViewState {
    override func viewShouldReloadData(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetching())
        machine.fetchProducts()
    }

    override func viewDidStartProductFetch(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateFetching())
        machine.fetchProducts()
    }

    override func didPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }

    override func viewDidStartPurchaseRestoration(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class StoreViewStatePurchasing: StoreViewState {
    override func didPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }

    override func didFailPurchasingProduct(machine machine: StoreViewStateMachine, error: String) {
        machine.changeState(StoreViewStatePurchaseError())
        machine.showPurchaseError(error)
    }
}

class StoreViewStatePurchased: StoreViewState {
    override func viewShouldReloadData(machine machine: StoreViewStateMachine) {
        machine.showThankYou()
    }
}

class StoreViewStatePurchaseError: StoreViewState {
    override func viewDidMakePurchase(machine machine: StoreViewStateMachine, product: PresentationProduct) {
        machine.purchaseProduct(identifier: product.identifier)
    }

    override func didStartPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchasing())
        machine.showPurchaseProgress()
    }

    override func viewDidStartPurchaseRestoration(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class StoreViewStateRestoringPurchases: StoreViewState {
    override func didPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }

    override func didRestorePurchases(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }

    override func didFailRestoringPurchases(machine machine: StoreViewStateMachine, error: String) {
        machine.changeState(StoreViewStatePurchaseRestorationError())
        machine.showPurchaseRestorationError(error)
    }
}

class StoreViewStatePurchaseRestorationError: StoreViewState {
    override func didPurchase(machine machine: StoreViewStateMachine, product: Product) {
        machine.changeState(StoreViewStatePurchased())
        machine.showThankYou()
    }

    override func viewDidStartPurchaseRestoration(machine machine: StoreViewStateMachine) {
        machine.changeState(StoreViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

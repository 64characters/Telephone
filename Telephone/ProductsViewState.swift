//
//  ProductsViewState.swift
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
// NoProducts      ViewDidStartPurchaseRestoration Restoring       RestorePurchases
//
// Fetching        DidFetchProducts                Fetched         ShowProducts
// Fetching        DidFailFetchingProducts         FetchError      ShowProductsFetchError
// Fetched         ViewDidMakePurchase             Purchasing      PurchaseProduct
// Fetched         ViewDidStartPurchaseRestoration Restoring       RestorePurchasesViewDid
// FetchError      ViewShouldReloadData            Fetching        FetchProducts
// FetchError      ViewDidStartProductFetch        Fetching        FetchProducts
// FetchError      ViewDidStartPurchaseRestoration Restoring       RestorePurchases
//
// Purchasing      DidPurchase                     Purchased       ShowThankYou
// Purchasing      DidFailPurchasingProduct        PurchaseError   ShowPurchaseError
// Purchased       ViewShouldReloadData            Purchased       ShowThankYou
// PurchaseError   ViewDidMakePurchase             Purchasing      PurchaseProduct
// PurchaseError   ViewDidStartPurchaseRestoration Restoring       RestorePurchases
//
// Restoring       DidRestorePurchases             Purchased       ShowThankYou
// Restoring       DidFailRestoringPurchases       RestoreError    ShowRestoreError
// RestoreError    ViewDidStartPurchaseRestoration Restoring       RestorePurchases


class ProductsViewState {
    func viewShouldReloadData(machine machine: ProductsViewStateMachine) {
        print("\(#function) is not supported for \(self)")
    }

    func viewDidStartProductFetch(machine machine: ProductsViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFetchProducts(machine machine: ProductsViewStateMachine, products: [Product])  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailFetchingProducts(machine machine: ProductsViewStateMachine, error: String)  {
        print("\(#function) is not supported for \(self)")
    }

    func viewDidMakePurchase(machine machine: ProductsViewStateMachine, product: PresentationProduct)  {
        print("\(#function) is not supported for \(self)")
    }

    func didPurchase(machine machine: ProductsViewStateMachine, product: Product)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailPurchasingProduct(machine machine: ProductsViewStateMachine, error: String)  {
        print("\(#function) is not supported for \(self)")
    }

    func viewDidStartPurchaseRestoration(machine machine: ProductsViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didRestorePurchases(machine machine: ProductsViewStateMachine)  {
        print("\(#function) is not supported for \(self)")
    }

    func didFailRestoringPurchases(machine machine: ProductsViewStateMachine, error: String)  {
        print("\(#function) is not supported for \(self)")
    }
}

class ProductsViewStateNoProducts: ProductsViewState {
    override func viewShouldReloadData(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateFetching())
        machine.fetchProducts()
    }

    override func viewDidStartProductFetch(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateFetching())
        machine.fetchProducts()
    }

    override func viewDidStartPurchaseRestoration(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class ProductsViewStateFetching: ProductsViewState {
    override func didFetchProducts(machine machine: ProductsViewStateMachine, products: [Product]) {
        machine.changeState(ProductsViewStateFetched())
        machine.showProducts(products)
    }

    override func didFailFetchingProducts(machine machine: ProductsViewStateMachine, error: String) {
        machine.changeState(ProductsViewStateFetchError())
        machine.showProductsFetchError(error)
    }
}

class ProductsViewStateFetched: ProductsViewState {
    override func viewDidMakePurchase(machine machine: ProductsViewStateMachine, product: PresentationProduct) {
        machine.changeState(ProductsViewStatePurchasing())
        machine.purchaseProduct(identifier: product.identifier)
    }

    override func viewDidStartPurchaseRestoration(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class ProductsViewStateFetchError: ProductsViewState {
    override func viewShouldReloadData(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateFetching())
        machine.fetchProducts()
    }

    override func viewDidStartProductFetch(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateFetching())
        machine.fetchProducts()
    }

    override func viewDidStartPurchaseRestoration(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class ProductsViewStatePurchasing: ProductsViewState {
    override func didPurchase(machine machine: ProductsViewStateMachine, product: Product) {
        machine.changeState(ProductsViewStatePurchased())
        machine.showThankYou()
    }

    override func didFailPurchasingProduct(machine machine: ProductsViewStateMachine, error: String) {
        machine.changeState(ProductsViewStatePurchaseError())
        machine.showPurchaseError(error)
    }
}

class ProductsViewStatePurchased: ProductsViewState {
    override func viewShouldReloadData(machine machine: ProductsViewStateMachine) {
        machine.showThankYou()
    }
}

class ProductsViewStatePurchaseError: ProductsViewState {
    override func viewDidMakePurchase(machine machine: ProductsViewStateMachine, product: PresentationProduct) {
        machine.changeState(ProductsViewStatePurchasing())
        machine.purchaseProduct(identifier: product.identifier)
    }

    override func viewDidStartPurchaseRestoration(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

class ProductsViewStateRestoringPurchases: ProductsViewState {
    override func didRestorePurchases(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStatePurchased())
        machine.showThankYou()
    }

    override func didFailRestoringPurchases(machine machine: ProductsViewStateMachine, error: String) {
        machine.changeState(ProductsViewStatePurchaseRestorationError())
        machine.showPurchaseRestorationError(error)
    }
}

class ProductsViewStatePurchaseRestorationError: ProductsViewState {
    override func viewDidStartPurchaseRestoration(machine machine: ProductsViewStateMachine) {
        machine.changeState(ProductsViewStateRestoringPurchases())
        machine.restorePurchases()
    }
}

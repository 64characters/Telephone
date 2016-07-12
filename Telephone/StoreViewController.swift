//
//  StoreViewController.swift
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

import Cocoa
import UseCases

class StoreViewController: NSViewController {
    private var target: StoreViewEventTarget = NullStoreViewEventTarget()
    private dynamic var products: [PresentationProduct] = []

    @IBOutlet private var productsListView: NSView!
    @IBOutlet private var productsFetchErrorView: NSView!
    @IBOutlet private var progressView: NSView!

    @IBOutlet private weak var productsContentView: NSView!
    @IBOutlet private weak var restorePurchasesButton: NSButton!
    @IBOutlet private weak var productsFetchErrorField: NSTextField!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!

    init() {
        super.init(nibName: "StoreViewController", bundle: nil)!
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        target.viewShouldReloadData(self)
    }

    func updateEventTarget(target: StoreViewEventTarget) {
        self.target = target
    }

    @IBAction func fetchProducts(sender: AnyObject) {
        target.viewDidStartProductFetch()
    }
}

extension StoreViewController: StoreView {
    func showProducts(products: [PresentationProduct]) {
        self.products = products
        showInProductsContentView(productsListView)
    }

    func showProductsFetchError(error: String) {
        productsFetchErrorField.stringValue = error
        showInProductsContentView(productsFetchErrorView)
    }

    func showProductsFetchProgress() {
        showProgress()
    }

    func showPurchaseProgress() {
        showProgress()
    }

    func disablePurchaseRestoration() {
        restorePurchasesButton.enabled = false
    }

    func enablePurchaseRestoration() {
        restorePurchasesButton.enabled = true
    }

    private func showInProductsContentView(view: NSView) {
        productsContentView.subviews.forEach { $0.removeFromSuperview() }
        productsContentView.addSubview(view)
    }

    private func showProgress() {
        progressIndicator.startAnimation(self)
        showInProductsContentView(progressView)
    }
}

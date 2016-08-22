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

final class StoreViewController: NSViewController {
    private var target: StoreViewEventTarget
    private var workspace: NSWorkspace
    private dynamic var products: [PresentationProduct] = []
    private let formatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateStyle = .ShortStyle
        return f
    }()

    @IBOutlet private var productsListView: NSView!
    @IBOutlet private var productsTableView: NSTableView!
    @IBOutlet private var productsFetchErrorView: NSView!
    @IBOutlet private var progressView: NSView!
    @IBOutlet private var purchasedView: NSView!
    @IBOutlet private var restorePurchasesButton: NSButton!
    @IBOutlet private var subscriptionsButton: NSButton!

    @IBOutlet private weak var productsContentView: NSView!
    @IBOutlet private weak var productsFetchErrorField: NSTextField!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var expirationField: NSTextField!

    init(target: StoreViewEventTarget, workspace: NSWorkspace) {
        self.target = target
        self.workspace = workspace
        super.init(nibName: "StoreViewController", bundle: nil)!
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        target.viewShouldReloadData(self)
    }

    func updateTarget(target: StoreViewEventTarget) {
        self.target = target
    }

    @IBAction func fetchProducts(sender: AnyObject) {
        target.viewDidStartProductFetch()
    }

    @IBAction func purchaseProduct(sender: NSButton) {
        target.viewDidMakePurchase(products[productsTableView.rowForView(sender)])
    }

    @IBAction func restorePurchases(sender: AnyObject) {
        target.viewDidStartPurchaseRestoration()
    }

    @IBAction func manageSubscriptions(sender: AnyObject) {
        workspace.openURL(NSURL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!)
    }
}

extension StoreViewController: StoreView {
    func showPurchaseCheckProgress() {
        showProgress()
    }

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

    func showPurchaseError(error: String) {
        purchaseErrorAlert(text: error).beginSheetModalForWindow(view.window!, completionHandler: nil)
    }

    func showPurchaseRestorationProgress() {
        showProgress()
    }

    func showPurchaseRestorationError(error: String) {
        restorationErrorAlert(text: error).beginSheetModalForWindow(view.window!, completionHandler: nil)
    }

    func disablePurchaseRestoration() {
        restorePurchasesButton.enabled = false
    }

    func enablePurchaseRestoration() {
        subscriptionsButton.hidden = true
        restorePurchasesButton.hidden = false
        restorePurchasesButton.enabled = true
    }

    func showPurchased(until date: NSDate) {
        expirationField.stringValue = formatter.stringFromDate(date)
        showInProductsContentView(purchasedView)
    }

    func showSubscriptionManagement() {
        restorePurchasesButton.hidden = true
        subscriptionsButton.hidden = false
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

extension StoreViewController: NSTableViewDelegate {}

private func purchaseErrorAlert(text text: String) -> NSAlert {
    return alert(message: NSLocalizedString("Could not make purchase.", comment: "Product purchase error."), text: text)
}

private func restorationErrorAlert(text text: String) -> NSAlert {
    return alert(message: NSLocalizedString("Could not restore purchases.", comment: "Purchase restoration error"), text: text)
}

private func alert(message message: String, text: String) -> NSAlert {
    let result = NSAlert()
    result.messageText = message
    result.informativeText = text
    return result
}

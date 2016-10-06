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
    fileprivate dynamic var products: [PresentationProduct] = []
    fileprivate let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()

    @IBOutlet private var productsTableView: NSTableView!
    @IBOutlet fileprivate var productsListView: NSView!
    @IBOutlet fileprivate var productsFetchErrorView: NSView!
    @IBOutlet fileprivate var progressView: NSView!
    @IBOutlet fileprivate var purchasedView: NSView!
    @IBOutlet fileprivate var restorePurchasesButton: NSButton!
    @IBOutlet fileprivate var refreshReceiptButton: NSButton!
    @IBOutlet fileprivate var subscriptionsButton: NSButton!

    @IBOutlet fileprivate weak var productsContentView: NSView!
    @IBOutlet fileprivate weak var productsFetchErrorField: NSTextField!
    @IBOutlet fileprivate weak var progressIndicator: NSProgressIndicator!
    @IBOutlet fileprivate weak var expirationField: NSTextField!

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

    func updateTarget(_ target: StoreViewEventTarget) {
        self.target = target
    }

    @IBAction func fetchProducts(_ sender: NSButton) {
        target.viewDidStartProductFetch()
    }

    @IBAction func purchaseProduct(_ sender: NSButton) {
        target.viewDidMakePurchase(product: products[productsTableView.row(for: sender)])
    }

    @IBAction func restorePurchases(_ sender: NSButton) {
        target.viewDidStartPurchaseRestoration()
    }

    @IBAction func refreshReceipt(_ sender: NSButton) {
        makeReceiptRefreshAlert().beginSheetModal(for: view.window!) { response in
            if response == NSAlertFirstButtonReturn {
                self.target.viewDidStartReceiptRefresh()
            }
        }
    }

    @IBAction func manageSubscriptions(_ sender: NSButton) {
        workspace.open(URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!)
    }
}

extension StoreViewController: StoreView {
    func showPurchaseCheckProgress() {
        showProgress()
    }

    func show(_ products: [PresentationProduct]) {
        self.products = products
        showInProductsContentView(productsListView)
    }

    func showProductsFetchError(_ error: String) {
        productsFetchErrorField.stringValue = error
        showInProductsContentView(productsFetchErrorView)
    }

    func showProductsFetchProgress() {
        showProgress()
    }

    func showPurchaseProgress() {
        showProgress()
    }

    func showPurchaseError(_ error: String) {
        makePurchaseErrorAlert(text: error).beginSheetModal(for: view.window!, completionHandler: nil)
    }

    func showPurchaseRestorationProgress() {
        showProgress()
    }

    func showPurchaseRestorationError(_ error: String) {
        makeRestorationErrorAlert(text: error).beginSheetModal(for: view.window!, completionHandler: nil)
    }

    func disablePurchaseRestoration() {
        restorePurchasesButton.isEnabled = false
        refreshReceiptButton.isEnabled = false;
    }

    func enablePurchaseRestoration() {
        subscriptionsButton.isHidden = true
        restorePurchasesButton.isHidden = false
        refreshReceiptButton.isHidden = false
        restorePurchasesButton.isEnabled = true
        refreshReceiptButton.isEnabled = true
    }

    func showPurchased(until date: Date) {
        expirationField.stringValue = formatter.string(from: date)
        showInProductsContentView(purchasedView)
    }

    func showSubscriptionManagement() {
        restorePurchasesButton.isHidden = true
        refreshReceiptButton.isHidden = true
        subscriptionsButton.isHidden = false
    }

    private func showInProductsContentView(_ view: NSView) {
        productsContentView.subviews.forEach { $0.removeFromSuperview() }
        productsContentView.addSubview(view)
    }

    private func showProgress() {
        progressIndicator.startAnimation(self)
        showInProductsContentView(progressView)
    }
}

extension StoreViewController: NSTableViewDelegate {}

private func makePurchaseErrorAlert(text: String) -> NSAlert {
    return makeAlert(message: NSLocalizedString("Could not make purchase.", comment: "Product purchase error."), text: text)
}

private func makeRestorationErrorAlert(text: String) -> NSAlert {
    return makeAlert(message: NSLocalizedString("Could not restore purchases.", comment: "Purchase restoration error."), text: text)
}

private func makeAlert(message: String, text: String) -> NSAlert {
    let result = NSAlert()
    result.messageText = message
    result.informativeText = text
    return result
}

private func makeReceiptRefreshAlert() -> NSAlert {
    let result = NSAlert()
    result.messageText = NSLocalizedString("Refresh receipt?", comment: "Receipt refresh alert message text.")
    result.informativeText = NSLocalizedString(
        "Telepohne will quit and the system will attempt to refresh the application receipt. " +
        "After that, Telephone will be started again. " +
        "You may be asked to enter your App Store credentials.",
        comment: "Receipt refresh alert informative text."
    )
    result.addButton(withTitle: NSLocalizedString("Quit and Refresh", comment: "Receipt refresh alert button."))
    result.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel button."))
    result.buttons[1].keyEquivalent = "\u{1b}"
    return result
}

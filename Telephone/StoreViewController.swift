//
//  StoreViewController.swift
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

import Cocoa
import UseCases

final class StoreViewController: NSViewController {
    private var target: StoreViewEventTarget
    private var workspace: NSWorkspace
    @objc private dynamic var products: [PresentationProduct] = []
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()

    @IBOutlet private var productsTableView: NSTableView!
    @IBOutlet private var productsListView: NSView!
    @IBOutlet private var productsFetchErrorView: NSView!
    @IBOutlet private var progressView: NSView!
    @IBOutlet private var purchasedView: NSView!
    @IBOutlet private var termsOfUseField: NSTextField!
    @IBOutlet private var privacyPolicyField: NSTextField!
    @IBOutlet private var restorePurchasesButton: NSButton!
    @IBOutlet private var refreshReceiptButton: NSButton!
    @IBOutlet private var subscriptionsButton: NSButton!

    @IBOutlet private weak var productsContentView: NSView!
    @IBOutlet private weak var productsFetchErrorField: NSTextField!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var expirationField: NSTextField!

    init(target: StoreViewEventTarget, workspace: NSWorkspace) {
        self.target = target
        self.workspace = workspace
        super.init(nibName: "StoreViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeHyperlinks()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        target.shouldReloadData()
    }

    func updateTarget(_ target: StoreViewEventTarget) {
        self.target = target
    }

    @IBAction func fetchProducts(_ sender: NSButton) {
        target.didStartProductFetch()
    }

    @IBAction func purchaseProduct(_ sender: NSButton) {
        target.didStartPurchasing(products[productsTableView.row(for: sender)])
    }

    @IBAction func restorePurchases(_ sender: NSButton) {
        target.didStartPurchaseRestoration()
    }

    @IBAction func refreshReceipt(_ sender: NSButton) {
        makeReceiptRefreshAlert().beginSheetModal(for: view.window!) { response in
            if response == .alertFirstButtonReturn {
                self.target.didStartReceiptRefresh()
            }
        }
    }

    @IBAction func manageSubscriptions(_ sender: NSButton) {
        workspace.open(URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!)
    }

    private func makeHyperlinks() {
        makeHyperlink(from: termsOfUseField, url: URL(string: "https://www.64characters.com/terms-and-conditions/")!)
        makeHyperlink(from: privacyPolicyField, url: URL(string: "https://www.64characters.com/privacy/")!)
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
    result.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel button.")).keyEquivalent = "\u{1b}"
    return result
}

private func makeHyperlink(from field: NSTextField, url: URL) {
    field.attributedStringValue = makeHyperlink(from: field.attributedStringValue, url: url)
}

private func makeHyperlink(from string: NSAttributedString, url: URL) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: string)
    result.addAttribute(.link, value: url, range: NSRange(location: 0, length: result.length))
    return result
}

//
//  ReceiptValidatingStoreEventTarget.swift
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

public final class ReceiptValidatingStoreEventTarget {
    private let origin: StoreEventTarget
    private let receipt: Receipt

    public init(origin: StoreEventTarget, receipt: Receipt) {
        self.origin = origin
        self.receipt = receipt
    }
}

extension ReceiptValidatingStoreEventTarget: StoreEventTarget {
    public func didStartPurchasingProduct(withIdentifier identifier: String) {
        origin.didStartPurchasingProduct(withIdentifier: identifier)
    }

    public func didPurchaseProducts() {
        receipt.validate { result in
            self.notifyOriginAboutPurchase(withReceiptValidationResult: result)
        }
    }

    public func didFailPurchasingProducts(error error: String) {
        origin.didFailPurchasingProducts(error: error)
    }

    public func didFailPurchasingProducts() {
        origin.didFailPurchasingProducts()
    }

    public func didRestorePurchases() {
        receipt.validate { result in
            self.notifyOriginAboutRestoration(withReceiptValidationResult: result)
        }
    }

    public func didFailRestoringPurchases(error error: String) {
        origin.didFailRestoringPurchases(error: error)
    }

    public func didCancelRestoringPurchases() {
        origin.didCancelRestoringPurchases()
    }

    private func notifyOriginAboutPurchase(withReceiptValidationResult result: ReceiptValidationResult) {
        switch result {
        case .ReceiptIsValid:
            self.origin.didPurchaseProducts()
        default:
            self.origin.didFailPurchasingProducts(error: result.message)
        }
    }

    private func notifyOriginAboutRestoration(withReceiptValidationResult result: ReceiptValidationResult) {
        switch result {
        case .ReceiptIsValid:
            origin.didRestorePurchases()
        default:
            origin.didFailRestoringPurchases(error: result.message)
        }
    }
}

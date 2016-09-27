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
    fileprivate let origin: StoreEventTarget
    fileprivate let receipt: Receipt

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
            self.notifyOriginAboutPurchase(with: result)
        }
    }

    public func didFailPurchasingProducts(error: String) {
        origin.didFailPurchasingProducts(error: error)
    }

    public func didCancelPurchasingProducts() {
        origin.didCancelPurchasingProducts()
    }

    public func didRestorePurchases() {
        receipt.validate { result in
            self.notifyOriginAboutRestoration(with: result)
        }
    }

    public func didFailRestoringPurchases(error: String) {
        origin.didFailRestoringPurchases(error: error)
    }

    public func didCancelRestoringPurchases() {
        origin.didCancelRestoringPurchases()
    }

    private func notifyOriginAboutPurchase(with result: ReceiptValidationResult) {
        switch result {
        case .receiptIsValid:
            self.origin.didPurchaseProducts()
        default:
            self.origin.didFailPurchasingProducts(error: result.localizedDescription)
        }
    }

    private func notifyOriginAboutRestoration(with result: ReceiptValidationResult) {
        switch result {
        case .receiptIsValid:
            origin.didRestorePurchases()
        default:
            origin.didFailRestoringPurchases(error: result.localizedDescription)
        }
    }
}

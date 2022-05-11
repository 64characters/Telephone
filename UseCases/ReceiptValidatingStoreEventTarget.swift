//
//  ReceiptValidatingStoreEventTarget.swift
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

    public func didPurchase() {
        receipt.validate { result in
            self.notifyOriginAboutPurchase(with: result)
        }
    }

    public func didFailPurchasing(error: String) {
        origin.didFailPurchasing(error: error)
    }

    public func didCancelPurchasing() {
        origin.didCancelPurchasing()
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
        if case .receiptIsValid = result {
            origin.didPurchase()
        } else {
            origin.didFailPurchasing(error: result.localizedDescription)
        }
    }

    private func notifyOriginAboutRestoration(with result: ReceiptValidationResult) {
        if case .receiptIsValid = result {
            origin.didRestorePurchases()
        } else {
            origin.didFailRestoringPurchases(error: result.localizedDescription)
        }
    }
}

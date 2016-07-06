//
//  ReceiptValidatingProductPurchaseEventTarget.swift
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

public final class ReceiptValidatingProductPurchaseEventTarget {
    private let origin: ProductPurchaseEventTarget
    private let receipt: ProductPurchaseReceipt

    public init(origin: ProductPurchaseEventTarget, receipt: ProductPurchaseReceipt) {
        self.origin = origin
        self.receipt = receipt
    }
}

extension ReceiptValidatingProductPurchaseEventTarget: ProductPurchaseEventTarget {
    public func didStartPurchasing(product: Product) {
        origin.didStartPurchasing(product)
    }

    public func didPurchase(product: Product) {
        if receipt.isValid () {
            origin.didPurchase(product)
        } else {
            origin.didFailPurchasing(product, error: receiptValidationError())
        }
    }

    public func didFailPurchasing(product: Product, error: String) {
        origin.didFailPurchasing(product, error: error)
    }

    public func didFailPurchasing(product: Product) {
        origin.didFailPurchasing(product)
    }
}

private func receiptValidationError() -> String {
    return NSLocalizedString("Could not validate purchase receipt", comment: "Receipt validation error.")
}

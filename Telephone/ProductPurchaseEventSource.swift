//
//  ProductPurchaseEventSource.swift
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

import StoreKit
import UseCases

final class ProductPurchaseEventSource: NSObject {
    private let queue: SKPaymentQueue
    private let products: Products
    private let target: ProductPurchaseEventTarget

    init(queue: SKPaymentQueue, products: Products, target: ProductPurchaseEventTarget) {
        self.queue = queue
        self.products = products
        self.target = target
        super.init()
        queue.addTransactionObserver(self)
    }

    deinit {
        queue.removeTransactionObserver(self)
    }
}

extension ProductPurchaseEventSource: SKPaymentTransactionObserver {
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        dispatch_async(dispatch_get_main_queue()) {
            transactions.forEach(self.handleStateChangeOf)
        }
    }

    private func handleStateChangeOf(transaction: SKPaymentTransaction) {
        if let product = products[transaction.payment.productIdentifier] {
            handleStateChangeOf(transaction, product: product)
        } else {
            print("Could not find product with id \(transaction.payment.productIdentifier)")
        }

    }

    private func handleStateChangeOf(transaction: SKPaymentTransaction, product: Product) {
        switch transaction.transactionState {
        case SKPaymentTransactionStatePurchasing:
            target.didStartPurchasing(product)
        case SKPaymentTransactionStatePurchased:
            target.didPurchase(product)
            queue.finishTransaction(transaction)
        case SKPaymentTransactionStateFailed:
            handleFaliedStateOf(transaction, product: product)
            queue.finishTransaction(transaction)
        default:
            print("Unhandled state change for transaction: \(transaction)")
        }
    }

    private func handleFaliedStateOf(transaction: SKPaymentTransaction, product: Product) {
        if let error = transaction.error {
            notifyTargetAboutFailedPurchaseOf(product, error: error)
        } else {
            target.didFailPurchasing(product, error: localizedUnknownError())
        }
    }

    private func notifyTargetAboutFailedPurchaseOf(product: Product, error: NSError) {
        if shouldReturnError(error) {
            target.didFailPurchasing(product, error: error.localizedDescription)
        } else {
            target.didFailPurchasing(product)
        }
    }
}

private func shouldReturnError(error: NSError) -> Bool {
    return !(error.domain == SKErrorDomain && error.code == SKErrorPaymentCancelled)
}

private func localizedUnknownError() -> String {
    return NSLocalizedString("Unknown error", comment: "Unknown error.")
}

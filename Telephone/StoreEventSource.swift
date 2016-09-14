//
//  StoreEventSource.swift
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

final class StoreEventSource: NSObject {
    private let queue: SKPaymentQueue
    private let target: StoreEventTarget

    init(queue: SKPaymentQueue, target: StoreEventTarget) {
        self.queue = queue
        self.target = target
        super.init()
        queue.addTransactionObserver(self)
    }

    deinit {
        queue.removeTransactionObserver(self)
    }
}

extension StoreEventSource: SKPaymentTransactionObserver {
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.handleStateChange(of: transactions)
        }
    }

    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            self.notifyTargetAboutFailedRestoration(error: error)
        }
    }

    private func handleStateChange(of transactions: [SKPaymentTransaction]) {
        handlePurchasing(transactions.filter { $0.transactionState == .Purchasing })
        handlePurchased(transactions.filter { $0.transactionState == .Purchased })
        handleFailed(transactions.filter { $0.transactionState == .Failed })
        handleRestored(transactions.filter { $0.transactionState == .Restored })
    }

    private func handlePurchasing(transactions: [SKPaymentTransaction]) {
        transactions.forEach { target.didStartPurchasingProduct(withIdentifier: $0.payment.productIdentifier) }
    }

    private func handlePurchased(transactions: [SKPaymentTransaction]) {
        if transactions.count > 0 { target.didPurchaseProducts() }
        transactions.forEach { queue.finishTransaction($0) }
    }

    private func handleFailed(transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            notifyTargetAboutFailure(of: $0)
            queue.finishTransaction($0)
        }
    }

    private func handleRestored(transactions: [SKPaymentTransaction]) {
        if transactions.count > 0 { target.didRestorePurchases() }
        transactions.forEach { queue.finishTransaction($0) }
    }

    private func notifyTargetAboutFailure(of transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            notifyTargetAboutFailedPurchase(error: error)
        } else {
            target.didFailPurchasingProducts(error: localizedUnknownError())
        }
    }

    private func notifyTargetAboutFailedPurchase(error error: NSError) {
        if isCancelled(error) {
            target.didCancelPurchasingProducts()
        } else {
            target.didFailPurchasingProducts(error: error.localizedDescription)
        }
    }

    private func notifyTargetAboutFailedRestoration(error error: NSError) {
        if isCancelled(error) {
            target.didCancelRestoringPurchases()
        } else {
            target.didFailRestoringPurchases(error: error.localizedDescription)
        }
    }
}

private func isCancelled(error: NSError) -> Bool {
    return error.domain == SKErrorDomain && error.code == SKErrorCode.PaymentCancelled.rawValue
}

private func localizedUnknownError() -> String {
    return NSLocalizedString("Unknown error", comment: "Unknown error.")
}

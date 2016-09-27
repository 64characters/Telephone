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
    fileprivate let queue: SKPaymentQueue
    fileprivate let target: StoreEventTarget

    init(queue: SKPaymentQueue, target: StoreEventTarget) {
        self.queue = queue
        self.target = target
        super.init()
        queue.add(self)
    }

    deinit {
        queue.remove(self)
    }
}

extension StoreEventSource: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async {
            self.handleStateChange(of: transactions)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.notifyTargetAboutFailedRestoration(error: error)
        }
    }

    private func handleStateChange(of transactions: [SKPaymentTransaction]) {
        handlePurchasing(transactions.filter { $0.transactionState == .purchasing })
        handlePurchased(transactions.filter { $0.transactionState == .purchased })
        handleFailed(transactions.filter { $0.transactionState == .failed })
        handleRestored(transactions.filter { $0.transactionState == .restored })
    }

    private func handlePurchasing(_ transactions: [SKPaymentTransaction]) {
        transactions.forEach { target.didStartPurchasingProduct(withIdentifier: $0.payment.productIdentifier) }
    }

    private func handlePurchased(_ transactions: [SKPaymentTransaction]) {
        if transactions.count > 0 { target.didPurchaseProducts() }
        transactions.forEach { queue.finishTransaction($0) }
    }

    private func handleFailed(_ transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            notifyTargetAboutFailure(of: $0)
            queue.finishTransaction($0)
        }
    }

    private func handleRestored(_ transactions: [SKPaymentTransaction]) {
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

    private func notifyTargetAboutFailedPurchase(error: Error) {
        if isCancelled(error) {
            target.didCancelPurchasingProducts()
        } else {
            target.didFailPurchasingProducts(error: error.localizedDescription)
        }
    }

    private func notifyTargetAboutFailedRestoration(error: Error) {
        if isCancelled(error) {
            target.didCancelRestoringPurchases()
        } else {
            target.didFailRestoringPurchases(error: error.localizedDescription)
        }
    }
}

private func isCancelled(_ error: Error) -> Bool {
    if let error = error as? SKError, error.code == .paymentCancelled  {
        return true
    } else {
        return false
    }
}

private func localizedUnknownError() -> String {
    return NSLocalizedString("Unknown error", comment: "Unknown error.")
}

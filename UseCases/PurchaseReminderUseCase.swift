//
//  PurchaseReminderUseCase.swift
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

import Foundation

public protocol PurchaseReminderUseCaseOutput {
    func remindAboutPurchasing()
}

public final class PurchaseReminderUseCase: NSObject {
    fileprivate let accounts: SavedAccounts
    fileprivate let receipt: Receipt
    fileprivate let defaults: PurchaseReminderUserDefaults
    fileprivate let now: Date
    fileprivate let version: String
    fileprivate let output: PurchaseReminderUseCaseOutput

    public init(accounts: SavedAccounts, receipt: Receipt, defaults: PurchaseReminderUserDefaults, now: Date, version: String, output: PurchaseReminderUseCaseOutput) {
        self.accounts = accounts
        self.receipt = receipt
        self.defaults = defaults
        self.now = now
        self.version = version
        self.output = output
    }
}

extension PurchaseReminderUseCase: UseCase {
    public func execute() {
        if accounts.haveEnabled && shouldRemind() {
            receipt.validate(completion: remindIfNotPurchased)
            self.updateDefautls()
        }
    }

    private func shouldRemind() -> Bool {
        return lastVersionDoesNotMatch() || isLastDateLaterThanNow() || haveThirtyDaysPassedSinceLastDate()
    }

    private func remindIfNotPurchased(_ result: ReceiptValidationResult) {
        switch result {
        case .receiptIsInvalid, .noActivePurchases:
            self.output.remindAboutPurchasing()
        default:
            break
        }
    }

    private func updateDefautls() {
        defaults.date = now
        defaults.version = version
    }

    private func lastVersionDoesNotMatch() -> Bool {
        return defaults.version != version
    }

    private func isLastDateLaterThanNow() -> Bool {
        return defaults.date.compare(now) == .orderedDescending
    }

    private func haveThirtyDaysPassedSinceLastDate() -> Bool {
        guard let date = thirtyDays(after: defaults.date) else { return false }
        return now >= date
    }
}

private func thirtyDays(after date: Date) -> Date? {
    return Calendar.current.date(byAdding: .day, value: 30, to: date)
}

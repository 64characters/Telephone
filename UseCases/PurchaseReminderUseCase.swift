//
//  PurchaseReminderUseCase.swift
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

import Foundation

public protocol PurchaseReminderUseCaseOutput {
    func remindAboutPurchasing()
}

public final class PurchaseReminderUseCase: NSObject {
    private let accounts: Accounts
    private let receipt: Receipt
    private let settings: PurchaseReminderSettings
    private let now: Date
    private let version: String
    private let output: PurchaseReminderUseCaseOutput

    public init(accounts: Accounts, receipt: Receipt, settings: PurchaseReminderSettings, now: Date, version: String, output: PurchaseReminderUseCaseOutput) {
        self.accounts = accounts
        self.receipt = receipt
        self.settings = settings
        self.now = now
        self.version = version
        self.output = output
    }
}

extension PurchaseReminderUseCase: UseCase {
    public func execute() {
        if accounts.haveEnabled && shouldRemind() {
            receipt.validate(completion: remindIfNotPurchased)
            self.updateSettings()
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

    private func updateSettings() {
        settings.date = now
        settings.version = version
    }

    private func lastVersionDoesNotMatch() -> Bool {
        return settings.version != version
    }

    private func isLastDateLaterThanNow() -> Bool {
        return settings.date.compare(now) == .orderedDescending
    }

    private func haveThirtyDaysPassedSinceLastDate() -> Bool {
        guard let date = thirtyDays(after: settings.date) else { return false }
        return now >= date
    }
}

private func thirtyDays(after date: Date) -> Date? {
    return Calendar.current.date(byAdding: .day, value: 30, to: date)
}

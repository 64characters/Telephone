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

public final class PurchaseReminderUseCase {
    private let accounts: SavedAccounts
    private let defaults: PurchaseReminderUserDefaults
    private let now: NSDate
    private let version: String
    private let output: PurchaseReminderUseCaseOutput

    public init(accounts: SavedAccounts, defaults: PurchaseReminderUserDefaults, now: NSDate, version: String, output: PurchaseReminderUseCaseOutput) {
        self.accounts = accounts
        self.defaults = defaults
        self.now = now
        self.version = version
        self.output = output
    }
}

extension PurchaseReminderUseCase: UseCase {
    public func execute() {
        if accounts.haveEnabled && shouldRemind() {
            output.remindAboutPurchasing()
            updateDefautls()
        }
    }

    private func shouldRemind() -> Bool {
        return lastVersionDoesNotMatch() || isLastDateLaterThanNow() || haveThirtyDaysPassedSinceLastDate()
    }

    private func updateDefautls() {
        defaults.lastPurchaseReminderDate = now
        defaults.lastPurchaseReminderVersion = version
    }

    private func lastVersionDoesNotMatch() -> Bool {
        return defaults.lastPurchaseReminderVersion != version
    }

    private func isLastDateLaterThanNow() -> Bool {
        return defaults.lastPurchaseReminderDate.compare(now) == .OrderedDescending
    }

    private func haveThirtyDaysPassedSinceLastDate() -> Bool {
        guard let date = thirtyDaysAfter(defaults.lastPurchaseReminderDate) else { return false }
        return now.laterDate(date) == now
    }
}

private func thirtyDaysAfter(date: NSDate) -> NSDate? {
    return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 30, toDate: date, options: [])
}

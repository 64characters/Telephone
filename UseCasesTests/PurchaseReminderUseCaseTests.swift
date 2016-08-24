//
//  PurchaseReminderUseCaseTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

final class PurchaseReminderUseCaseTests: XCTestCase {
    func testDoesNotRemindWhenThereAreNoEnabledAccounts() {
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = NSDate.distantPast()
        defaults.lastPurchaseReminderVersion = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: DisabledSavedAccountsStub(), defaults: defaults, now: NSDate(), version: "any", output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenMoreThanThirtyDaysPassedSinceLastReminder() {
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = NSDate.distantPast()
        defaults.lastPurchaseReminderVersion = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(), defaults: defaults, now: NSDate(), version: "any", output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testDoesNotRemindWhenLessThanThirtyDaysPassedSinceLastReminder() {
        let now = NSDate()
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = oneSecondAfter(thirtyDaysBefore(now))
        defaults.lastPurchaseReminderVersion = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(), defaults: defaults, now: now, version: "any", output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenExactlyThirtyDaysPassedSinceLastReminder() {
        let now = NSDate()
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = thirtyDaysBefore(now)
        defaults.lastPurchaseReminderVersion = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(), defaults: defaults, now: now, version: "any", output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testRemindsWhenLastReminderDateIsLaterThanNow() {
        let now = NSDate()
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = oneSecondAfter(now)
        defaults.lastPurchaseReminderVersion = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(), defaults: defaults, now: now, version: "any", output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testDoesNotRemindWhenLastReminderDateIsExactlyNow() {
        let now = NSDate()
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = now
        defaults.lastPurchaseReminderVersion = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(), defaults: defaults, now: now, version: "any", output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenLessThanThirtyDaysPassedSinceLastReminderAndLastReminderVersionDoesNotMatchCurrentVersion() {
        let now = NSDate()
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = oneSecondAfter(thirtyDaysBefore(now))
        defaults.lastPurchaseReminderVersion = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(), defaults: defaults, now: now, version: "other", output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testSavesCurrentDateAndVersionToUserDefaultsWhenReminds() {
        let now = NSDate()
        let defaults = UserDefaultsFake()
        defaults.lastPurchaseReminderDate = oneSecondAfter(now)
        defaults.lastPurchaseReminderVersion = "old"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(), defaults: defaults, now: now, version: "new", output: output
        )

        sut.execute()

        XCTAssertEqual(defaults.lastPurchaseReminderDate, now)
        XCTAssertEqual(defaults.lastPurchaseReminderVersion, "new")
    }
}

private func thirtyDaysBefore(date: NSDate) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -30, toDate: date, options: [])!
}

private func oneSecondAfter(date: NSDate) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(.Second, value: 1, toDate: date, options: [])!
}

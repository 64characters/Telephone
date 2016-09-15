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
        defaults.date = Date.distantPast
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: DisabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: Date(),
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testDoesNotRemindWhenReceiptIsValid() {
        let defaults = UserDefaultsFake()
        defaults.date = Date.distantPast
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: ValidReceipt(),
            defaults: defaults,
            now: Date(),
            version: "other",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenMoreThanThirtyDaysPassedSinceLastReminder() {
        let defaults = UserDefaultsFake()
        defaults.date = Date.distantPast
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: Date(),
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testDoesNotRemindWhenLessThanThirtyDaysPassedSinceLastReminder() {
        let now = Date()
        let defaults = UserDefaultsFake()
        defaults.date = oneSecondAfter(thirtyDaysBefore(now))
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenExactlyThirtyDaysPassedSinceLastReminder() {
        let now = Date()
        let defaults = UserDefaultsFake()
        defaults.date = thirtyDaysBefore(now)
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testRemindsWhenLastReminderDateIsLaterThanNow() {
        let now = Date()
        let defaults = UserDefaultsFake()
        defaults.date = oneSecondAfter(now)
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testDoesNotRemindWhenLastReminderDateIsExactlyNow() {
        let now = Date()
        let defaults = UserDefaultsFake()
        defaults.date = now
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenLessThanThirtyDaysPassedSinceLastReminderAndLastReminderVersionDoesNotMatchCurrentVersion() {
        let now = Date()
        let defaults = UserDefaultsFake()
        defaults.date = oneSecondAfter(thirtyDaysBefore(now))
        defaults.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: now,
            version: "other",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testSavesCurrentDateAndVersionToUserDefaultsWhenReminds() {
        let now = Date()
        let defaults = UserDefaultsFake()
        defaults.date = oneSecondAfter(now)
        defaults.version = "old"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledSavedAccountsStub(),
            receipt: InvalidReceipt(),
            defaults: defaults,
            now: now,
            version: "new",
            output: output
        )

        sut.execute()

        XCTAssertEqual(defaults.date, now)
        XCTAssertEqual(defaults.version, "new")
    }
}

private func thirtyDaysBefore(_ date: Date) -> Date {
    return (Calendar.current as NSCalendar).date(byAdding: .day, value: -30, to: date, options: [])!
}

private func oneSecondAfter(_ date: Date) -> Date {
    return (Calendar.current as NSCalendar).date(byAdding: .second, value: 1, to: date, options: [])!
}

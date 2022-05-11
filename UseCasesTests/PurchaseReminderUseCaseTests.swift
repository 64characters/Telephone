//
//  PurchaseReminderUseCaseTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

final class PurchaseReminderUseCaseTests: XCTestCase {
    func testDoesNotRemindWhenThereAreNoEnabledAccounts() {
        let settings = SettingsFake()
        settings.date = Date.distantPast
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: DisabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: Date(),
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testDoesNotRemindWhenReceiptIsValid() {
        let settings = SettingsFake()
        settings.date = Date.distantPast
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: ValidReceipt(),
            settings: settings,
            now: Date(),
            version: "other",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenMoreThanThirtyDaysPassedSinceLastReminder() {
        let settings = SettingsFake()
        settings.date = Date.distantPast
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: Date(),
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testDoesNotRemindWhenLessThanThirtyDaysPassedSinceLastReminder() {
        let now = Date()
        let settings = SettingsFake()
        settings.date = oneSecondAfter(thirtyDaysBefore(now))
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenExactlyThirtyDaysPassedSinceLastReminder() {
        let now = Date()
        let settings = SettingsFake()
        settings.date = thirtyDaysBefore(now)
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testRemindsWhenLastReminderDateIsLaterThanNow() {
        let now = Date()
        let settings = SettingsFake()
        settings.date = oneSecondAfter(now)
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testDoesNotRemindWhenLastReminderDateIsExactlyNow() {
        let now = Date()
        let settings = SettingsFake()
        settings.date = now
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: now,
            version: "any",
            output: output
        )

        sut.execute()

        XCTAssertFalse(output.didCallRemind)
    }

    func testRemindsWhenLessThanThirtyDaysPassedSinceLastReminderAndLastReminderVersionDoesNotMatchCurrentVersion() {
        let now = Date()
        let settings = SettingsFake()
        settings.date = oneSecondAfter(thirtyDaysBefore(now))
        settings.version = "any"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: now,
            version: "other",
            output: output
        )

        sut.execute()

        XCTAssertTrue(output.didCallRemind)
    }

    func testSavesCurrentDateAndVersionToSettingsWhenReminds() {
        let now = Date()
        let settings = SettingsFake()
        settings.date = oneSecondAfter(now)
        settings.version = "old"
        let output = PurchaseReminderUseCaseOutputSpy()
        let sut = PurchaseReminderUseCase(
            accounts: EnabledAccountsStub(),
            receipt: InvalidReceipt(),
            settings: settings,
            now: now,
            version: "new",
            output: output
        )

        sut.execute()

        XCTAssertEqual(settings.date, now)
        XCTAssertEqual(settings.version, "new")
    }
}

private func thirtyDaysBefore(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: -30, to: date)!
}

private func oneSecondAfter(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .second, value: 1, to: date)!
}

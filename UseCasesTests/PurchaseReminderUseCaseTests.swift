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

import Foundation
import Testing
import UseCases
import UseCasesTestDoubles

@MainActor
struct PurchaseReminderUseCaseTests {
    @Test func doesNotRemindWhenThereAreNoEnabledAccounts() async {
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

        await sut.execute()

        #expect(!output.didCallRemind)
    }

    @Test func doesNotRemindWhenReceiptIsValid() async {
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

        await sut.execute()

        #expect(!output.didCallRemind)
    }

    @Test func remindsWhenMoreThanThirtyDaysPassedSinceLastReminder() async {
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

        await sut.execute()

        #expect(output.didCallRemind)
    }

    @Test func doesNotRemindWhenLessThanThirtyDaysPassedSinceLastReminder() async {
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

        await sut.execute()

        #expect(!output.didCallRemind)
    }

    @Test func remindsWhenExactlyThirtyDaysPassedSinceLastReminder() async {
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

        await sut.execute()

        #expect(output.didCallRemind)
    }

    @Test func remindsWhenLastReminderDateIsLaterThanNow() async {
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

        await sut.execute()

        #expect(output.didCallRemind)
    }

    @Test func doesNotRemindWhenLastReminderDateIsExactlyNow() async {
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

        await sut.execute()

        #expect(!output.didCallRemind)
    }

    @Test func remindsWhenLessThanThirtyDaysPassedSinceLastReminderAndLastReminderVersionDoesNotMatchCurrentVersion() async {
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

        await sut.execute()

        #expect(output.didCallRemind)
    }

    @Test func savesCurrentDateAndVersionToSettingsWhenReminds() async {
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

        await sut.execute()

        #expect(settings.date == now)
        #expect(settings.version == "new")
    }
}

private func thirtyDaysBefore(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: -30, to: date)!
}

private func oneSecondAfter(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .second, value: 1, to: date)!
}

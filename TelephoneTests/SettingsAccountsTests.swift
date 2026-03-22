//
//  SettingsAccountsTests.swift
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

import Testing
import UseCases
import UseCasesTestDoubles

@MainActor
struct SettingsAccountsTests {
    @Test func haveEnabledIsTrueWhenAtLeastOneAccountIsEnabled() {
        let settings = SettingsFake()
        settings.set(
            [
                [UserDefaultsKeys.accountEnabled: false],
                [UserDefaultsKeys.accountEnabled: true],
                [UserDefaultsKeys.accountEnabled: false]
            ],
            forKey: UserDefaultsKeys.accounts
        )

        let sut = SettingsAccounts(settings: settings)

        #expect(sut.haveEnabled)
    }

    @Test func haveEnabledIsFalseWhenThereAreNoEnabledAccounts() {
        let settings = SettingsFake()
        settings.set(
            [
                [UserDefaultsKeys.accountEnabled: false],
                [UserDefaultsKeys.accountEnabled: false],
                [UserDefaultsKeys.accountEnabled: false]
            ],
            forKey: UserDefaultsKeys.accounts
        )

        let sut = SettingsAccounts(settings: settings)

        #expect(!sut.haveEnabled)
    }
}

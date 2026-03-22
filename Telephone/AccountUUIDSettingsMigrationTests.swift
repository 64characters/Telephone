//
//  AccountUUIDSettingsMigrationTests.swift
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
import UseCasesTestDoubles

@MainActor
struct AccountUUIDSettingsMigrationTests {
    @Test func addsUUID() throws {
        let settings = SettingsFake()
        settings.set(
            [[UserDefaultsKeys.accountEnabled: true], [UserDefaultsKeys.accountEnabled: false]],
            forKey: UserDefaultsKeys.accounts
        )
        let sut = AccountUUIDSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(UUID(uuidString: try #require(accounts[0][AKSIPAccountKeys.uuid] as? String)) != nil)
        #expect(UUID(uuidString: try #require(accounts[1][AKSIPAccountKeys.uuid] as? String)) != nil)
    }

    @Test func doesNotChangeExistingUUID() throws {
        let settings = SettingsFake()
        settings.set(
            [
                [UserDefaultsKeys.accountEnabled: true, AKSIPAccountKeys.uuid: "foo"],
                [UserDefaultsKeys.accountEnabled: false, AKSIPAccountKeys.uuid: "bar"]
            ],
            forKey: UserDefaultsKeys.accounts
        )
        let sut = AccountUUIDSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.uuid] as? String == "foo")
        #expect(accounts[1][AKSIPAccountKeys.uuid] as? String == "bar")
    }

    @Test func changesExistingUUIDIfItIsEmpty() throws {
        let settings = SettingsFake()
        settings.set(
            [[UserDefaultsKeys.accountEnabled: true, AKSIPAccountKeys.uuid: ""]], forKey: UserDefaultsKeys.accounts
        )
        let sut = AccountUUIDSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(UUID(uuidString: try #require(accounts[0][AKSIPAccountKeys.uuid] as? String)) != nil)
    }
}

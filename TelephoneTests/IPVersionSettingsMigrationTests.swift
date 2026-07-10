//
//  IPVersionSettingsMigrationTests.swift
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
struct IPVersionSettingsMigrationTests {
    @Test func addsIPVersionFromUseIPv6OnlyKey() throws {
        let settings = SettingsFake()
        settings.set(
            [[AKSIPAccountKeys.useIPv6Only: false], [AKSIPAccountKeys.useIPv6Only: true]],
            forKey: UserDefaultsKeys.accounts
        )
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.ipVersion] as? String == AKSIPAccountKeys.ipVersion4)
        #expect(accounts[1][AKSIPAccountKeys.ipVersion] as? String == AKSIPAccountKeys.ipVersion6)
    }

    @Test func addsIPVersion4WhenUseIPv6OnlyKeyDoesNotExist() throws {
        let settings = SettingsFake()
        settings.set([[:]], forKey: UserDefaultsKeys.accounts)
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.ipVersion] as? String == AKSIPAccountKeys.ipVersion4)
    }

    @Test func doesNotChangeExistingIPVersion() throws {
        let settings = SettingsFake()
        settings.set(
            [[AKSIPAccountKeys.ipVersion: "foo"], [AKSIPAccountKeys.ipVersion: "bar"]],
            forKey: UserDefaultsKeys.accounts
        )
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.ipVersion] as? String == "foo")
        #expect(accounts[1][AKSIPAccountKeys.ipVersion] as? String == "bar")
    }

    @Test func changesExistingIPVersionTo4IfItIsEmpty() throws {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.ipVersion: ""]], forKey: UserDefaultsKeys.accounts)
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.ipVersion] as? String == AKSIPAccountKeys.ipVersion4)
    }

    @Test func removesUseIPv6OnlyKey() throws {
        let settings = SettingsFake()
        settings.set(
            [[AKSIPAccountKeys.useIPv6Only: false], [AKSIPAccountKeys.useIPv6Only: true]],
            forKey: UserDefaultsKeys.accounts
        )
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.useIPv6Only] == nil)
        #expect(accounts[1][AKSIPAccountKeys.useIPv6Only] == nil)
    }
}

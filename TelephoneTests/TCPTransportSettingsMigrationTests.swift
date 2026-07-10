//
//  TCPTransportSettingsMigrationTests.swift
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
struct TCPTransportSettingsMigrationTests {
    @Test func setsTransportToTCPIfProxyHostHasTCPTransportParameter() throws {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any;transport=tcp"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.transport] as? String == AKSIPAccountKeys.transportTCP)
    }

    @Test func doesNotSetTransportIfProxyHostDoesNotHaveTCPTransportParameter() throws {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.transport] == nil)
    }

    @Test func removesProxyHostTCPTransportParameterWhenItIsASuffix() throws {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any;transport=tcp"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.proxyHost] as? String == "any")
    }

    @Test func removesProxyHostTCPTransportParameterWhenItIsLocatedInTheMiddle() throws {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any;transport=tcp;hide"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = try #require(settings.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]])
        #expect(accounts[0][AKSIPAccountKeys.proxyHost] as? String == "any;hide")
    }
}

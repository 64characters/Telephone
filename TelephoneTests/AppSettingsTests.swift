//
//  AppSettingsTests.swift
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

final class AppSettingsTests: XCTestCase {
    func testReturnsSettingsVersion() {
        let settings = SettingsFake()
        settings.set(3, forKey: UserDefaultsKeys.settingsVersion)
        let sut = AppSettings(settings: settings, defaults: [:], accountDefaults: [:])

        XCTAssertEqual(sut.stringValue, "\(UserDefaultsKeys.settingsVersion): 3")
    }

    func testReturnsEmptyStringWhenNoValuesAreSet() {
        XCTAssertEqual(AppSettings(settings: SettingsFake(), defaults: [:], accountDefaults: [:]).stringValue, "")
    }

    func testExcludesDefaultSettings() {
        let settings = SettingsFake()
        settings.set(true, forKey: UserDefaultsKeys.useDNSSRV)
        let sut = AppSettings(settings: settings, defaults: [UserDefaultsKeys.useDNSSRV: true], accountDefaults: [:])

        XCTAssertEqual(sut.stringValue, "")
    }

    func testReturnsValuesInAlphabeticalOrderOfTheKeys() {
        let settings = SettingsFake()
        settings.set(true, forKey: UserDefaultsKeys.useDNSSRV)
        settings.set(4, forKey: UserDefaultsKeys.logLevel)
        settings[UserDefaultsKeys.stunServerHost] = "any"

        XCTAssertEqual(
            AppSettings(settings: settings, defaults: [:], accountDefaults: [:]).stringValue,
            "\(UserDefaultsKeys.logLevel): 4\n\(UserDefaultsKeys.stunServerHost): \"any\"\n\(UserDefaultsKeys.useDNSSRV): true"
        )
    }

    func testReturnsAccountValuesInAlphabeticalOrderOfTheKeys() {
        let settings = SettingsFake()
        settings.set(
            [
                [
                    UserDefaultsKeys.accountEnabled: true,
                    AKSIPAccountKeys.uuid: "any-uuid",
                    AKSIPAccountKeys.domain: "any-domain"
                ]
            ],
            forKey: UserDefaultsKeys.accounts
        )

        let sut = AppSettings(settings: settings, defaults: [:], accountDefaults: [:])

        XCTAssertEqual(
            sut.stringValue,
            "\n" +
            "\(UserDefaultsKeys.accounts): {\n" +
            "\t\(UserDefaultsKeys.accountEnabled): true\n" +
            "\t\(AKSIPAccountKeys.domain): \"any-domain\"\n" +
            "\t\(AKSIPAccountKeys.uuid): \"any-uuid\"\n" +
            "}"
        )
    }

    func testReturnsMultipleAccountsInTheirOriginalOrder() {
        let settings = SettingsFake()
        settings.set(
            [
                [
                    UserDefaultsKeys.accountEnabled: false,
                    AKSIPAccountKeys.username: "any-username-1",
                    AKSIPAccountKeys.domain: "any-domain-1"
                ],
                [
                    UserDefaultsKeys.accountEnabled: true,
                    AKSIPAccountKeys.username: "any-username-2",
                    AKSIPAccountKeys.domain: "any-domain-2"
                ]
            ],
            forKey: UserDefaultsKeys.accounts
        )

        let sut = AppSettings(settings: settings, defaults: [:], accountDefaults: [:])

        XCTAssertEqual(
            sut.stringValue,
            "\n" +
            "\(UserDefaultsKeys.accounts): {\n" +
            "\t\(UserDefaultsKeys.accountEnabled): false\n" +
            "\t\(AKSIPAccountKeys.domain): \"any-domain-1\"\n" +
            "\t\(AKSIPAccountKeys.username): \"any-username-1\"\n" +
            "} {\n" +
            "\t\(UserDefaultsKeys.accountEnabled): true\n" +
            "\t\(AKSIPAccountKeys.domain): \"any-domain-2\"\n" +
            "\t\(AKSIPAccountKeys.username): \"any-username-2\"\n" +
            "}"
        )
    }

    func testExcludesDefaultAccountSettings() {
        let settings = SettingsFake()
        settings.set(
            [
                [
                    UserDefaultsKeys.accountEnabled: false,
                    AKSIPAccountKeys.username: "any-username-1",
                    AKSIPAccountKeys.domain: "any-domain-1",
                    AKSIPAccountKeys.useProxy: false,
                    AKSIPAccountKeys.proxyPort: 123,
                    AKSIPAccountKeys.transport: AKSIPAccountKeys.transportTLS
                ],
                [
                    UserDefaultsKeys.accountEnabled: true,
                    AKSIPAccountKeys.username: "any-username-2",
                    AKSIPAccountKeys.domain: "any-domain-2",
                    AKSIPAccountKeys.useProxy: false,
                    AKSIPAccountKeys.proxyPort: 123,
                    AKSIPAccountKeys.transport: AKSIPAccountKeys.transportTLS
                ]
            ],
            forKey: UserDefaultsKeys.accounts
        )

        let sut = AppSettings(
            settings: settings,
            defaults: [:],
            accountDefaults: [
                AKSIPAccountKeys.useProxy: false,
                AKSIPAccountKeys.proxyPort: 123,
                AKSIPAccountKeys.transport: AKSIPAccountKeys.transportTLS
            ]
        )

        XCTAssertEqual(
            sut.stringValue,
            "\n" +
            "\(UserDefaultsKeys.accounts): {\n" +
            "\t\(UserDefaultsKeys.accountEnabled): false\n" +
            "\t\(AKSIPAccountKeys.domain): \"any-domain-1\"\n" +
            "\t\(AKSIPAccountKeys.username): \"any-username-1\"\n" +
            "} {\n" +
            "\t\(UserDefaultsKeys.accountEnabled): true\n" +
            "\t\(AKSIPAccountKeys.domain): \"any-domain-2\"\n" +
            "\t\(AKSIPAccountKeys.username): \"any-username-2\"\n" +
            "}"
        )
    }
}

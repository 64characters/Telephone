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

import UseCasesTestDoubles
import XCTest

final class TCPTransportSettingsMigrationTests: XCTestCase {
    func testSetsTransportToTCPIfProxyHostHasTCPTransportParameter() {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any;transport=tcp"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: UserDefaultsKeys.accounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][AKSIPAccountKeys.transport] as! String, AKSIPAccountKeys.transportTCP)
    }

    func testDoesNotSetTransportIfProxyHostDoesNotHaveTCPTransportParameter() {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: UserDefaultsKeys.accounts) as! [[String: Any]]
        XCTAssertNil(accounts[0][AKSIPAccountKeys.transport])
    }

    func testRemovesProxyHostTCPTransportParameterWhenItIsASuffix() {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any;transport=tcp"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: UserDefaultsKeys.accounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][AKSIPAccountKeys.proxyHost] as! String, "any")
    }

    func testRemovesProxyHostTCPTransportParameterWhenItIsLocatedInTheMiddle() {
        let settings = SettingsFake()
        settings.set([[AKSIPAccountKeys.proxyHost: "any;transport=tcp;hide"]], forKey: UserDefaultsKeys.accounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: UserDefaultsKeys.accounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][AKSIPAccountKeys.proxyHost] as! String, "any;hide")
    }
}

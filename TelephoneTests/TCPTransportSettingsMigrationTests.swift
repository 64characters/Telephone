//
//  TCPTransportSettingsMigrationTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2021 64 Characters
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
        settings.set([[kProxyHost: "any;transport=tcp"]], forKey: kAccounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][kTransport] as! String, kTransportTCP)
    }

    func testDoesNotSetTransportIfProxyHostDoesNotHaveTCPTransportParameter() {
        let settings = SettingsFake()
        settings.set([[kProxyHost: "any"]], forKey: kAccounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertNil(accounts[0][kTransport])
    }

    func testRemovesProxyHostTCPTransportParameterWhenItIsASuffix() {
        let settings = SettingsFake()
        settings.set([[kProxyHost: "any;transport=tcp"]], forKey: kAccounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][kProxyHost] as! String, "any")
    }

    func testRemovesProxyHostTCPTransportParameterWhenItIsLocatedInTheMiddle() {
        let settings = SettingsFake()
        settings.set([[kProxyHost: "any;transport=tcp;hide"]], forKey: kAccounts)
        let sut = TCPTransportSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][kProxyHost] as! String, "any;hide")
    }
}

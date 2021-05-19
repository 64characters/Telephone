//
//  IPVersionSettingsMigrationTests.swift
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

final class IPVersionSettingsMigrationTests: XCTestCase {
    func testAddsIPVersionFromUseIPv6OnlyKey() {
        let settings = SettingsFake()
        settings.set([[kUseIPv6Only: false], [kUseIPv6Only: true]], forKey: kAccounts)
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][kIPVersion] as! String, kIPVersion4)
        XCTAssertEqual(accounts[1][kIPVersion] as! String, kIPVersion6)
    }

    func testAddsIPVersion4WhenUseIPv6OnlyKeyDoesNotExist() {
        let settings = SettingsFake()
        settings.set([[:]], forKey: kAccounts)
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][kIPVersion] as! String, kIPVersion4)
    }

    func testDoesNotChangeExistingIPVersion() {
        let settings = SettingsFake()
        settings.set([[kIPVersion: "foo"], [kIPVersion: "bar"]], forKey: kAccounts)
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertEqual((accounts[0][kIPVersion] as! String), "foo")
        XCTAssertEqual((accounts[1][kIPVersion] as! String), "bar")
    }

    func testChangesExistingIPVersionTo4IfItIsEmpty() {
        let settings = SettingsFake()
        settings.set([[kIPVersion: ""]], forKey: kAccounts)
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertEqual(accounts[0][kIPVersion] as! String, kIPVersion4)
    }

    func testRemovesUseIPv6OnlyKey() {
        let settings = SettingsFake()
        settings.set([[kUseIPv6Only: false], [kUseIPv6Only: true]], forKey: kAccounts)
        let sut = IPVersionSettingsMigration(settings: settings)

        sut.execute()

        let accounts = settings.array(forKey: kAccounts) as! [[String: Any]]
        XCTAssertNil(accounts[0][kUseIPv6Only])
        XCTAssertNil(accounts[1][kUseIPv6Only])
    }
}

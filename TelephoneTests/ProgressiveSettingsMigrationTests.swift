//
//  ProgressiveSettingsMigrationTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2020 64 Characters
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

final class ProgressiveSettingsMigrationTests: XCTestCase {

    // MARK: - AccountUUIDSettingsMigration

    func testExecutesAccountsUUIDMigrationWhenSettingsDoNotHaveVersion() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withAccountUUIDMigration: migration)
        let sut = ProgressiveSettingsMigration(settings: SettingsFake(), factory: factory)

        sut.execute()

        XCTAssertTrue(migration.didCallExecute)
    }

    func testDoesNotExecuteAccountUUIDMigrationWhenSettingsVersionIsEqualToOne() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withAccountUUIDMigration: migration)
        let settings = SettingsFake()
        settings.set(1, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    func testDoesNotExecuteAccountUUIDMigrationWhenSettingsVersionIsGreaterThanOne() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withAccountUUIDMigration: migration)
        let settings = SettingsFake()
        settings.set(2, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    // MARK: - IPVersionSettingsMigration

    func testExecutesIPVersionMigrationWhenSettingsVersionIsEqualToOne() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withIPVersionMigration: migration)
        let settings = SettingsFake()
        settings.set(1, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertTrue(migration.didCallExecute)
    }

    func testDoesNotExecuteIPVersionMigrationWhenSettingsVersionIsEqualToTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withIPVersionMigration: migration)
        let settings = SettingsFake()
        settings.set(2, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    func testDoesNotExecuteIPVersionMigrationWhenSettingsVersionIsGreaterThanTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withIPVersionMigration: migration)
        let settings = SettingsFake()
        settings.set(3, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    // MARK: - TCPTransportSettingsMigration

    func testExecutesTCPTransportMigrationWhenSettingsVersionIsEqualToOne() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withTCPTransportMigration: migration)
        let settings = SettingsFake()
        settings.set(1, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertTrue(migration.didCallExecute)
    }

    func testDoesNotExecuteTCPTransportMigrationWhenSettingsVersionIsEqualToTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withTCPTransportMigration: migration)
        let settings = SettingsFake()
        settings.set(2, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    func testDoesNotExecuteTCPTransportMigrationWhenSettingsVersionIsGreaterThanTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withTCPTransportMigration: migration)
        let settings = SettingsFake()
        settings.set(3, forKey: kSettingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    // MARK: - Versioning

    func testSetsSettingsVersionSequentiallyToOneAndTwo() {
        let settings = SettingsFake()
        let sut = ProgressiveSettingsMigration(settings: settings, factory: SettingsMigrationFactoryStub())

        sut.execute()

        XCTAssertEqual(settings.changelog as! [[String: Int]], [[kSettingsVersion: 1], [kSettingsVersion: 2]])
    }
}

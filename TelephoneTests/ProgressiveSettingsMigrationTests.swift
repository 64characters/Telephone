//
//  ProgressiveSettingsMigrationTests.swift
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

final class ProgressiveSettingsMigrationTests: XCTestCase {
    private var settings: SettingsFake!
    private var actions: String!

    override func setUp() {
        super.setUp()
        settings = SettingsFake()
        actions = ""
    }

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
        settings.set(1, forKey: UserDefaultsKeys.settingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    func testDoesNotExecuteAccountUUIDMigrationWhenSettingsVersionIsGreaterThanOne() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withAccountUUIDMigration: migration)
        let settings = SettingsFake()
        settings.set(2, forKey: UserDefaultsKeys.settingsVersion)
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
        settings.set(1, forKey: UserDefaultsKeys.settingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertTrue(migration.didCallExecute)
    }

    func testDoesNotExecuteIPVersionMigrationWhenSettingsVersionIsEqualToTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withIPVersionMigration: migration)
        let settings = SettingsFake()
        settings.set(2, forKey: UserDefaultsKeys.settingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    func testDoesNotExecuteIPVersionMigrationWhenSettingsVersionIsGreaterThanTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withIPVersionMigration: migration)
        let settings = SettingsFake()
        settings.set(3, forKey: UserDefaultsKeys.settingsVersion)
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
        settings.set(1, forKey: UserDefaultsKeys.settingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertTrue(migration.didCallExecute)
    }

    func testDoesNotExecuteTCPTransportMigrationWhenSettingsVersionIsEqualToTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withTCPTransportMigration: migration)
        let settings = SettingsFake()
        settings.set(2, forKey: UserDefaultsKeys.settingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    func testDoesNotExecuteTCPTransportMigrationWhenSettingsVersionIsGreaterThanTwo() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withTCPTransportMigration: migration)
        let settings = SettingsFake()
        settings.set(3, forKey: UserDefaultsKeys.settingsVersion)
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertFalse(migration.didCallExecute)
    }

    // MARK: - Migration sequence

    func testMigrationSequence() {
        ProgressiveSettingsMigration(settings: self, factory: self).execute()

        XCTAssertEqual(actions, "MauSv1MivMttSv2")
    }
}

extension ProgressiveSettingsMigrationTests: KeyValueSettings {
    subscript(key: String) -> String? {
        get { settings[key] }
        set(newValue) { settings[key] = newValue }
    }
    func string(forKey key: String) -> String? { settings.string(forKey: key) }
    func set(_ value: Bool, forKey key: String) { settings.set(value, forKey: key) }
    func bool(forKey key: String) -> Bool { settings.bool(forKey: key) }
    func set(_ value: Int, forKey key: String) {
        actions.append("Sv\(value)")
        settings.set(value, forKey: key)
    }
    func integer(forKey key: String) -> Int { settings.integer(forKey: key) }
    func set(_ array: [Any], forKey key: String) { settings.set(array, forKey: key) }
    func array(forKey key: String) -> [Any]? { settings.array(forKey: key) }
    func exists(forKey key: String) -> Bool { settings.exists(forKey: key) }
    func register(defaults: [String : Any]) { settings.register(defaults: defaults) }
}

extension ProgressiveSettingsMigrationTests: SettingsMigrationFactory {
    func makeAccountUUIDMigration() -> SettingsMigration {
        actions.append("Mau")
        return NullSettingsMigration()
    }

    func makeIPVersionMigration() -> SettingsMigration {
        actions.append("Miv")
        return NullSettingsMigration()
    }

    func makeTCPTransportMigration() -> SettingsMigration {
        actions.append("Mtt")
        return NullSettingsMigration()
    }
}

//
//  ProgressiveSettingsMigrationTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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
    func testExecutesAccountsUUIDMigrationWhenSettingsDoNotHaveVersion() {
        let migration = SettingsMigrationSpy()
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withAccountUUIDMigration: migration)
        let sut = ProgressiveSettingsMigration(settings: SettingsFake(), factory: factory)

        sut.execute()

        XCTAssertTrue(migration.didCallExecute)
    }

    func testSetsSettingsVersionToOneAfterAccountUUIDMigration() {
        let factory = SettingsMigrationFactoryStub()
        factory.stub(withAccountUUIDMigration: SettingsMigrationSpy())
        let settings = SettingsFake()
        let sut = ProgressiveSettingsMigration(settings: settings, factory: factory)

        sut.execute()

        XCTAssertEqual(settings.integer(forKey: kSettingsVersion), 1)
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
}

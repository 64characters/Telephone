//
//  SettingsMigrationFactoryStub.swift
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

final class SettingsMigrationFactoryStub {
    var accountUUID: SettingsMigration = NullSettingsMigration()
    var ipVersion: SettingsMigration = NullSettingsMigration()
    var tcpTransport: SettingsMigration = NullSettingsMigration()

    func stub(withAccountUUIDMigration migration: SettingsMigration) {
        accountUUID = migration
    }

    func stub(withIPVersionMigration migration: SettingsMigration) {
        ipVersion = migration
    }

    func stub(withTCPTransportMigration migration: SettingsMigration) {
        tcpTransport = migration
    }
}

extension SettingsMigrationFactoryStub: SettingsMigrationFactory {
    func makeAccountUUIDMigration() -> SettingsMigration {
        return accountUUID
    }

    func makeIPVersionMigration() -> SettingsMigration {
        return ipVersion
    }

    func makeTCPTransportMigration() -> SettingsMigration {
        return tcpTransport
    }
}

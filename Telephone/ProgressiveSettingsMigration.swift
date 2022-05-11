//
//  ProgressiveSettingsMigration.swift
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

final class ProgressiveSettingsMigration: NSObject {
    private let settings: KeyValueSettings
    private let factory: SettingsMigrationFactory

    init(settings: KeyValueSettings, factory: SettingsMigrationFactory) {
        self.settings = settings
        self.factory = factory
    }
}

extension ProgressiveSettingsMigration: SettingsMigration {
    @objc func execute() {
        if settings.integer(forKey: UserDefaultsKeys.settingsVersion) == 0 {
            factory.makeAccountUUIDMigration().execute()
            settings.set(1, forKey: UserDefaultsKeys.settingsVersion)
        }
        if settings.integer(forKey: UserDefaultsKeys.settingsVersion) == 1 {
            factory.makeIPVersionMigration().execute()
            factory.makeTCPTransportMigration().execute()
            settings.set(2, forKey: UserDefaultsKeys.settingsVersion)
        }
    }
}

//
//  AccountUUIDSettingsMigration.swift
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

final class AccountUUIDSettingsMigration {
    private let settings: KeyValueSettings

    init(settings: KeyValueSettings) {
        self.settings = settings
    }
}

extension AccountUUIDSettingsMigration: SettingsMigration {
    func execute() {
        settings.save(accounts: settings.loadAccounts().map(addingUUIDIfNeeded))
    }
}

private func addingUUIDIfNeeded(to dict: [String: Any]) -> [String: Any] {
    if shouldAddUUID(to: dict) {
        return addingUUID(to: dict)
    } else {
        return dict
    }
}

private func shouldAddUUID(to dict: [String: Any]) -> Bool {
    if let uuid = dict[AKSIPAccountKeys.uuid] as? String, !uuid.isEmpty {
        return false
    } else {
        return true
    }
}

private func addingUUID(to dict: [String: Any]) -> [String: Any] {
    var result = dict
    result[AKSIPAccountKeys.uuid] = UUID().uuidString
    return result
}

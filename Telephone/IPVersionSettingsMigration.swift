//
//  IPVersionSettingsMigration.swift
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

final class IPVersionSettingsMigration {
    private let settings: KeyValueSettings

    init(settings: KeyValueSettings) {
        self.settings = settings
    }
}

extension IPVersionSettingsMigration: SettingsMigration {
    func execute() {
        settings.save(accounts: settings.loadAccounts().map(addingIPVersionIfNeeded))
    }
}

private func addingIPVersionIfNeeded(to dict: [String: Any]) -> [String: Any] {
    if shouldAddIPVersion(to: dict) {
        return removingUseIPv6Only(from: addingIPVersion(to: dict))
    } else {
        return dict
    }
}

private func shouldAddIPVersion(to dict: [String: Any]) -> Bool {
    if let version = dict[AKSIPAccountKeys.ipVersion] as? String, !version.isEmpty {
        return false
    } else {
        return true
    }
}

private func addingIPVersion(to dict: [String: Any]) -> [String: Any] {
    var result = dict
    if let useIPv6 = result[AKSIPAccountKeys.useIPv6Only] as? Bool {
        result[AKSIPAccountKeys.ipVersion] = useIPv6 ? AKSIPAccountKeys.ipVersion6 : AKSIPAccountKeys.ipVersion4
    } else {
        result[AKSIPAccountKeys.ipVersion] = AKSIPAccountKeys.ipVersion4
    }
    return result
}

private func removingUseIPv6Only(from dict: [String: Any]) -> [String: Any] {
    var result = dict
    result[AKSIPAccountKeys.useIPv6Only] = nil
    return result
}

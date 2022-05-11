//
//  KeyValueSettings+UserDefaults.swift
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

extension KeyValueSettings {
    func loadAccounts() -> [[String: Any]] {
        return self.array(forKey: UserDefaultsKeys.accounts) as? [[String: Any]] ?? []
    }

    func save(accounts: [[String: Any]]) {
        self.set(accounts, forKey: UserDefaultsKeys.accounts)
    }
}

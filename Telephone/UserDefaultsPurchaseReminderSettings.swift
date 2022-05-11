//
//  UserDefaultsPurchaseReminderSettings.swift
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

import Foundation
import UseCases

final class UserDefaultsPurchaseReminderSettings {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
        defaults.register(defaults: [dateKey: Date.distantPast, versionKey: ""])
    }
}

extension UserDefaultsPurchaseReminderSettings: PurchaseReminderSettings {
    var date: Date {
        get {
            return defaults.object(forKey: dateKey) as! Date
        }
        set {
            defaults.set(newValue, forKey: dateKey)
        }
    }

    var version: String {
        get {
            return defaults.string(forKey: versionKey)!
        }
        set {
            defaults.set(newValue, forKey: versionKey)
        }
    }
}

private let dateKey = "PurchaseReminderDate"
private let versionKey = "PurchaseReminderVersion"

//
//  SimplePurchaseReminderUserDefaults.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

final class SimplePurchaseReminderUserDefaults {
    private let defaults: NSUserDefaults

    init(defaults: NSUserDefaults) {
        self.defaults = defaults
        defaults.registerDefaults([dateKey: NSDate.distantPast(), versionKey: ""])
    }
}

extension SimplePurchaseReminderUserDefaults: PurchaseReminderUserDefaults {
    var lastPurchaseReminderDate: NSDate {
        get {
            return defaults.objectForKey(dateKey) as! NSDate
        }
        set {
            defaults.setObject(newValue, forKey: dateKey)
        }
    }

    var lastPurchaseReminderVersion: String {
        get {
            return defaults.stringForKey(versionKey)!
        }
        set {
            defaults.setObject(newValue, forKey: versionKey)
        }
    }
}

private let dateKey = "LastPurchaseReminderDate"
private let versionKey = "LastPurchaseReminderVersion"

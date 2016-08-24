//
//  UserDefaultsFake.swift
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

public final class UserDefaultsFake {
    @objc public var date: NSDate = NSDate.distantPast()
    @objc public var version = ""

    private var dictionary: [String: String] = [:]

    public init() {}
}

extension UserDefaultsFake: KeyValueUserDefaults {
    @objc public subscript(key: String) -> String? {
        get {
            return dictionary[key]
        }
        set {
            dictionary[key] = newValue
        }
    }

    @objc public func stringForKey(key: String) -> String? {
        return dictionary[key]
    }
}

extension UserDefaultsFake: PurchaseReminderUserDefaults {}

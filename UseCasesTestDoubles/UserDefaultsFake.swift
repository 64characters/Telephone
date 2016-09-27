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
    public var date: Date = Date.distantPast
    public var version = ""

    public var registeredDefaults: [String: Any] {
        return registered
    }

    fileprivate var dictionary: [String: Any] = [:]
    fileprivate var registered: [String: Any] = [:]

    public init() {}
}

extension UserDefaultsFake: KeyValueUserDefaults {
    @objc public subscript(key: String) -> String? {
        get {
            return string(forKey: key)
        }
        set {
            dictionary[key] = newValue as Any?
        }
    }

    @objc public func string(forKey key: String) -> String? {
        return dictionary[key] as? String
    }

    @objc public func set(_ value: Bool, forKey key: String) {
        dictionary[key] = value
    }

    @objc public func bool(forKey key: String) -> Bool {
        return dictionary[key] as? Bool ?? false
    }

    @objc public func set(_ array: [Any], forKey key: String) {
        dictionary[key] = array
    }

    @objc public func array(forKey key: String) -> [Any]? {
        return dictionary[key] as? [Any]
    }

    @objc public func register(defaults: [String : Any]) {
        for (key, value) in defaults {
            registered.updateValue(value, forKey: key)
            dictionary.updateValue(value, forKey: key)
        }
    }
}

extension UserDefaultsFake: PurchaseReminderUserDefaults {}

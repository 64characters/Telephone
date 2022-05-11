//
//  SettingsFake.swift
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

public final class SettingsFake {
    public var date: Date = Date.distantPast
    public var version = ""

    public var registeredDefaults: [String: Any] { return registered }

    private var dictionary: [String: Any] = [:]
    private var registered: [String: Any] = [:]

    public init() {}
}

extension SettingsFake: KeyValueSettings {
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

    @objc public func set(_ value: Int, forKey key: String) {
        dictionary[key] = value
    }

    @objc public func integer(forKey key: String) -> Int {
        return dictionary[key] as? Int ?? 0
    }

    @objc public func set(_ array: [Any], forKey key: String) {
        dictionary[key] = array
    }

    @objc public func array(forKey key: String) -> [Any]? {
        return dictionary[key] as? [Any]
    }

    public func exists(forKey key: String) -> Bool {
        return dictionary[key] != nil
    }

    @objc public func register(defaults: [String : Any]) {
        for (key, value) in defaults {
            registered[key] = value
            if dictionary[key] == nil {
                dictionary[key] = value
            }
        }
    }
}

extension SettingsFake: PurchaseReminderSettings {}

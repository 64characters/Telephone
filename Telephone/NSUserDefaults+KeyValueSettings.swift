//
//  NSUserDefaults+KeyValueSettings.swift
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

extension UserDefaults: KeyValueSettings {
    public subscript(key: String) -> String? {
        get {
            return string(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }

    public func set(_ array: [Any], forKey key: String) {
        set(array as Any, forKey: key)
    }

    public func exists(forKey key: String) -> Bool {
        return object(forKey: key) != nil
    }
}

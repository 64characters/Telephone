//
//  KeyValueSettings.swift
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

@objc public protocol KeyValueSettings {
    subscript(key: String) -> String? { get set }
    func string(forKey key: String) -> String?

    @objc(setBool:forKey:)
    func set(_ value: Bool, forKey key: String)
    func bool(forKey key: String) -> Bool

    @objc(setInteger:forKey:)
    func set(_ value: Int, forKey key: String)
    func integer(forKey key: String) -> Int

    @objc(setArray:forKey:)
    func set(_ array: [Any], forKey key: String)
    func array(forKey key: String) -> [Any]?

    func exists(forKey key: String) -> Bool

    @objc(registerDefaults:)
    func register(defaults: [String: Any])
}

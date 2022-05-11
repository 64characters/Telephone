//
//  SimplePropertyListStorage.swift
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

final class SimplePropertyListStorage {
    private let url: URL
    private let manager: FileManager

    init(url: URL, manager: FileManager) {
        self.url = url
        self.manager = manager
    }
}

extension SimplePropertyListStorage: PropertyListStorage {
    func load() throws -> [[String : Any]] {
        do {
            let plist = try PropertyListSerialization.propertyList(from: try Data(contentsOf: url), options: [], format: nil)
            return plist as? [[String : Any]] ?? []
        } catch CocoaError.fileReadNoSuchFile {
            return []
        } catch {
            throw error
        }
    }

    func save(_ plist: [[String : Any]]) throws {
        try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
            .write(to: url, options: .atomic)
    }

    func delete() throws {
        do {
            try manager.removeItem(at: url)
        } catch CocoaError.fileNoSuchFile {
            // Do nothing.
        } catch {
            throw error
        }
    }
}

//
//  SimpleApplicationDataLocations.swift
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

final class SimpleApplicationDataLocations: NSObject {
    fileprivate let manager: FileManager
    fileprivate let bundle: Bundle

    init(manager: FileManager, bundle: Bundle) {
        self.manager = manager
        self.bundle = bundle
    }
}

extension SimpleApplicationDataLocations: ApplicationDataLocations {
    func logs() -> URL {
        return root()
    }

    func callHistories() -> URL {
        return root().appendingPathComponent("CallHistories", isDirectory: true)
    }

    private func root() -> URL {
        return applicationSupport().appendingPathComponent(bundle.bundleIdentifier!, isDirectory: true)
    }

    private func applicationSupport() -> URL {
        return manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
}

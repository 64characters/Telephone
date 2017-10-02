//
//  URI.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

public final class URI: NSObject {
    @objc public let user: String
    @objc public let host: String
    @objc public let displayName: String

    public init(user: String, host: String, displayName: String) {
        self.user = user
        self.host = host
        self.displayName = displayName
    }

    public override var description: String {
        if !displayName.isEmpty {
            return "\"\(displayName)\" <sip:\(user)@\(host)>"
        } else {
            return "<sip:\(user)@\(host)>"
        }
    }
}

extension URI {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let uri = object as? URI else { return false }
        return isEqual(to: uri)
    }

    public override var hash: Int {
        return user.hash ^ host.hash ^ displayName.hash
    }

    private func isEqual(to uri: URI) -> Bool {
        return user == uri.user && host == uri.host && displayName == uri.displayName
    }
}

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
    public let user: String
    public let host: String

    public init(user: String, host: String) {
        self.user = user
        self.host = host
    }

    public convenience init(_ address: ContactAddress) {
        self.init(user: address.user, host: address.host)
    }

    public override var description: String {
        return "\(user)@\(host)"
    }
}

extension URI {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let uri = object as? URI else { return false }
        return isEqual(to: uri)
    }

    public override var hash: Int {
        return user.hash ^ host.hash
    }

    private func isEqual(to uri: URI) -> Bool {
        return user == uri.user && host == uri.host
    }
}

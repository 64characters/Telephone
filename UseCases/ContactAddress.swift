//
//  ContactAddress.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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

public struct ContactAddress {
    public let user: String
    public let host: String

    public init(user: String, host: String = "") {
        assert(user.characters.count > 0)
        self.user = user
        self.host = host
    }

    public init(_ uri: URI) {
        self.init(user: uri.user, host: uri.host)
    }
}

extension ContactAddress: Equatable {
    public static func ==(lhs: ContactAddress, rhs: ContactAddress) -> Bool {
        return lhs.user == rhs.user && lhs.host == rhs.host
    }
}

//
//  MatchedContact.swift
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

public struct MatchedContact: Equatable {
    public let name: String
    public let address: Address

    public init(name: String, address: Address) {
        self.name = name
        self.address = address
    }

    public enum Address: Equatable {
        case phone(number: String, label: String)
        case email(address: String, label: String)
    }
}

extension MatchedContact {
    public init(uri: URI) {
        self.init(name: uri.displayName, address: Address(uri: uri))
    }
}

extension MatchedContact.Address {
    init(uri: URI) {
        if uri.host.isEmpty {
            self = .phone(number: uri.user, label: "")
        } else {
            self = .email(address: "\(uri.user)@\(uri.host)", label: "")
        }
    }
}

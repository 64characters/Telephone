//
//  MatchedContact.swift
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

public struct MatchedContact {
    public let name: String
    public let address: Address

    public init(name: String, address: Address) {
        self.name = name
        self.address = address
    }

    public enum Address {
        case phone(number: String, label: String)
        case email(address: String, label: String)
    }
}

extension MatchedContact: Equatable {
    public static func ==(lhs: MatchedContact, rhs: MatchedContact) -> Bool {
        return lhs.name == rhs.name && lhs.address == rhs.address
    }
}

extension MatchedContact.Address: Equatable {
    public static func ==(lhs: MatchedContact.Address, rhs: MatchedContact.Address) -> Bool {
        switch (lhs, rhs) {
        case let (.phone(number1, label1), .phone(number2, label2)):
            return number1 == number2 && label1 == label2
        case let (.email(address1, label1), .email(address2, label2)):
            return address1 == address2 && label1 == label2
        case (.phone, _), (.email, _):
            return false
        }
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

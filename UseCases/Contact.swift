//
//  Contact.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

public struct Contact {
    public let name: String
    public let phones: [Phone]
    public let emails: [Email]

    public init(name: String, phones: [Phone], emails: [Email]) {
        self.name = name
        self.phones = phones
        self.emails = emails
    }

    public struct Phone {
        public let number: String
        public let label: String

        public init(number: String, label: String) {
            self.number = number
            self.label = label
        }
    }

    public struct Email {
        public let address: String
        public let label: String

        public init(address: String, label: String) {
            self.address = address
            self.label = label
        }
    }
}

extension Contact: Equatable {
    public static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name == rhs.name && lhs.phones == rhs.phones && lhs.emails == rhs.emails
    }
}

extension Contact.Phone: Equatable {
    public static func ==(lhs: Contact.Phone, rhs: Contact.Phone) -> Bool {
        return lhs.number == rhs.number && lhs.label == rhs.label
    }
}

extension Contact.Email: Equatable {
    public static func ==(lhs: Contact.Email, rhs: Contact.Email) -> Bool {
        return lhs.address == rhs.address && lhs.label == rhs.label
    }
}

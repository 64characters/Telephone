//
//  Contact.swift
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

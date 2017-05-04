//
//  ContactMatchingIndex.swift
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

public final class ContactMatchingIndex {
    private let contacts: Contacts
    private var index: [String: MatchedContact] = [:]

    public init(contacts: Contacts) {
        self.contacts = contacts
    }

    public func build() {
        index.removeAll()
        contacts.enumerate { contact in
            contact.phones.forEach {
                index[$0.number] = MatchedContact(name: contact.name, address: .phone(number: $0.number, label: $0.label))
            }
            contact.emails.forEach {
                index[$0.address] = MatchedContact(name: contact.name, address: .email(address: $0.address, label: $0.label))
            }
        }
    }

    public func contact(forAddress address: String) -> MatchedContact? {
        return index[address]
    }
}

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
    private let index: [String: MatchedContact]

    public init(contacts: Contacts) {
        index = makeMap(from: contacts)
    }

    public func contact(forAddress address: String) -> MatchedContact? {
        return index[address]
    }
}

private func makeMap(from contacts: Contacts) -> [String: MatchedContact] {
    var result: [String: MatchedContact] = [:]
    contacts.enumerate { contact in
        contact.phones.forEach {
            result[$0.number] = MatchedContact(name: contact.name, address: .phone(number: $0.number, label: $0.label))
        }
        contact.emails.forEach {
            result[$0.address] = MatchedContact(name: contact.name, address: .email(address: $0.address, label: $0.label))
        }
    }
    return result
}

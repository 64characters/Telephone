//
//  SimpleContactMatchingIndex.swift
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

public struct SimpleContactMatchingIndex {
    private let index: [String: MatchedContact]

    public init(contacts: Contacts, maxPhoneNumberLength: Int) {
        index = makeMap(from: contacts, maxPhoneNumberLength: maxPhoneNumberLength)
    }
}

extension SimpleContactMatchingIndex: ContactMatchingIndex {
    public func contact(forPhone phone: ExtractedPhoneNumber) -> MatchedContact? {
        return index[phone.value]
    }

    public func contact(forEmail email: NormalizedLowercasedString) -> MatchedContact? {
        return index[email.value]
    }
}

private func makeMap(from contacts: Contacts, maxPhoneNumberLength: Int) -> [String: MatchedContact] {
    var result: [String: MatchedContact] = [:]
    contacts.enumerate { contact in
        update(&result, withPhonesOf: contact, maxPhoneNumberLength: maxPhoneNumberLength)
        update(&result, withEmailsOf: contact)
    }
    return result
}

private func update(_ map: inout [String: MatchedContact], withPhonesOf contact: Contact, maxPhoneNumberLength: Int) {
    contact.phones.forEach {
        update(&map, withAddress: ExtractedPhoneNumber($0.number, maxLength: maxPhoneNumberLength).value, of: contact, phone: $0)
    }
}

private func update(_ map: inout [String: MatchedContact], withEmailsOf contact: Contact) {
    contact.emails.forEach {
        update(&map, withAddress: NormalizedLowercasedString($0.address).value, of: contact, email: $0)
    }
}

private func update(_ map: inout [String: MatchedContact], withAddress address: String, of contact: Contact, phone: Contact.Phone) {
    guard !address.isEmpty else { return }
    map[address] = MatchedContact(name: contact.name, address: .phone(number: phone.number, label: phone.label))
}

private func update(_ map: inout [String: MatchedContact], withAddress address: String, of contact: Contact, email: Contact.Email) {
    guard !address.isEmpty else { return }
    map[address] = MatchedContact(name: contact.name, address: .email(address: email.address, label: email.label))
}

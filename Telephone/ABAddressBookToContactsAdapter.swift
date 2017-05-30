//
//  ABAddressBookToContactsAdapter.swift
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

import AddressBook
import UseCases

final class ABAddressBookToContactsAdapter {
    fileprivate lazy var book: ABAddressBook = ABAddressBook.shared()
    fileprivate lazy var nameOrdering: Int = self.book.defaultNameOrdering()
}

extension ABAddressBookToContactsAdapter: Contacts {
    func enumerate(_ body: @escaping (Contact) -> Void) {
        for record in book.people() {
            if let person = record as? ABPerson {
                body(Contact.init(person, nameOrdering: nameOrdering))
            }
        }
    }
}

private extension Contact {
    init(_ person: ABPerson, nameOrdering: Int) {
        self.init(
            name: person.ak_fullName(withNameOrdering: nameOrdering),
            phones: makePhones(of: person),
            emails: makeEmails(of: person)
        )
    }
}

private func makePhones(of person: ABPerson) -> [Contact.Phone] {
    var result: [Contact.Phone] = []
    if let phones = person.value(forProperty: kABPhoneProperty) as? ABMultiValue {
        for i in 0..<phones.count() {
            result.append(Contact.Phone(phones: phones, index: i))
        }
    }
    return result
}

private func makeEmails(of person: ABPerson) -> [Contact.Email] {
    var result: [Contact.Email] = []
    if let emails = person.value(forProperty: kABEmailProperty) as? ABMultiValue {
        for i in 0..<emails.count() {
            result.append(Contact.Email(emails: emails, index: i))
        }
    }
    return result
}

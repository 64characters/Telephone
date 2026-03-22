//
//  IndexedContactMatchingTests.swift
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

import Testing
import UseCases
import UseCasesTestDoubles

@ContactsActor
struct IndexedContactMatchingTests {
    @Test func matchesContactByEmail() async {
        let contact = Contact(name: "John Smith", phones: [], emails: [Contact.Email(address: "user@company.com", label: "work")])
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(contacts: SimpleContacts([contact]), maxPhoneNumberLength: 0),
            significantPhoneNumberLength: 0,
            domain: ""
        )

        let result = await sut.match(for: URI(user: "user", host: "company.com", displayName: "any-name"))

        #expect(result == MatchedContact(contact: contact, emailIndex: 0))
    }

    @Test func matchesContactByPhoneNumber() async {
        let contact = Contact(name: "John Smith", phones: [Contact.Phone(number: "0123456789", label: "home")], emails: [])
        let length = 10
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(contacts: SimpleContacts([contact]), maxPhoneNumberLength: length),
            significantPhoneNumberLength: length,
            domain: ""
        )

        let result = await sut.match(for: URI(user: contact.phones[0].number, host: "any-host", displayName: "any-name"))

        #expect(result == MatchedContact(contact: contact, phoneIndex: 0))
    }

    @Test func matchesContactByLastDigitsOfThePhoneNumberFromSettings() async {
        let contact = Contact(name: "John Smith", phones: [Contact.Phone(number: "0123456789", label: "home")], emails: [])
        let length = 7
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(contacts: SimpleContacts([contact]), maxPhoneNumberLength: length),
            significantPhoneNumberLength: length,
            domain: ""
        )

        let result = await sut.match(for: URI(user: "3456789", host: "any-host", displayName: "any-name"))

        #expect(result == MatchedContact(contact: contact, phoneIndex: 0))
    }

    @Test func matchesContactByEmailWhenBothEmailAndPhoneNumberExist() async {
        let contact1 = Contact(name: "John Smith", phones: [], emails: [Contact.Email(address: "0123456789@company.com", label: "work")])
        let contact2 = Contact(name: "Jane Doe", phones: [Contact.Phone(number: "0123456789", label: "home")], emails: [])
        let length = 10
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(contacts: SimpleContacts([contact1, contact2]), maxPhoneNumberLength: length),
            significantPhoneNumberLength: length,
            domain: ""
        )

        let result = await sut.match(for: URI(user: "0123456789", host: "company.com", displayName: "any"))

        #expect(result == MatchedContact(contact: contact1, emailIndex: 0))
    }

    @Test func matchesContactByPhoneNumberWhenContactPhoneContainsNonDigitCharacters() async {
        let contact = Contact(name: "John Smith", phones: [Contact.Phone(number: "(012) 345-6789", label: "home")], emails: [])
        let length = 10
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(contacts: SimpleContacts([contact]), maxPhoneNumberLength: length),
            significantPhoneNumberLength: length,
            domain: ""
        )

        let result = await sut.match(for: URI(user: "0123456789", host: "any-host", displayName: "any-name"))

        #expect(result == MatchedContact(contact: contact, phoneIndex: 0))
    }

    @Test func matchesContactByEmailWhenContactEmailContainsUppercaseCharacters() async {
        let contact = Contact(name: "Jane", phones: [], emails: [Contact.Email(address: "JohnSmith@Company.com", label: "work")])
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(contacts: SimpleContacts([contact]), maxPhoneNumberLength: 0),
            significantPhoneNumberLength: 0,
            domain: ""
        )

        let result = await sut.match(for: URI(user: "johnsmith", host: "Company.com", displayName: "any"))

        #expect(result == MatchedContact(contact: contact, emailIndex: 0))
    }

    @Test func matchesContactByEmailComposedOfURIUserAndDefaultDomainWhenURIHostIsEmpty() async {
        let contact = Contact(name: "Foo", phones: [], emails: [Contact.Email(address: "foo@bar.com", label: "work")])
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(contacts: SimpleContacts([contact]), maxPhoneNumberLength: 0),
            significantPhoneNumberLength: 0,
            domain: "bar.com"
        )

        let result = await sut.match(for: URI(user: "foo", host: "", displayName: "any"))

        #expect(result == MatchedContact(contact: contact, emailIndex: 0))
    }

    @Test func returnsNilWhenNothingIsFound() async {
        let sut = IndexedContactMatching(
            index: SimpleContactMatchingIndex(
                contacts: SimpleContacts(
                    [
                        Contact(
                            name: "John Smith",
                            phones: [Contact.Phone(number: "0123456789", label: "home")],
                            emails: [Contact.Email(address: "user@company.com", label: "work")]
                        )
                    ]
                ),
                maxPhoneNumberLength: 0
            ),
            significantPhoneNumberLength: 0,
            domain: ""
        )

        let result = await sut.match(for: URI(user: "foo", host: "bar", displayName: ""))

        #expect(result == nil)
    }
}

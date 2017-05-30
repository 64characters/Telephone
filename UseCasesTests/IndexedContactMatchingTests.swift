//
//  IndexedContactMatchingTests.swift
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

import XCTest
import UseCases
import UseCasesTestDoubles

final class IndexedContactMatchingTests: XCTestCase {
    func testDoesNotCreateIndexOnInit() {
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndex(contacts: SimpleContacts([]), maxPhoneNumberLength: 0))

        _ = IndexedContactMatching(factory: factory, settings: ContactMatchingSettingsFake(length: 0))

        XCTAssertFalse(factory.didCallMake)
    }

    func testCreatesIndexOnFirstSearch() {
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndex(contacts: SimpleContacts([]), maxPhoneNumberLength: 0))
        let sut = IndexedContactMatching(factory: factory, settings: ContactMatchingSettingsFake(length: 0))

        _ = sut.match(for: URI(user: "any", host: "any", displayName: "any"))

        XCTAssertTrue(factory.didCallMake)
    }

    func testCreatesIndexOnce() {
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndex(contacts: SimpleContacts([]), maxPhoneNumberLength: 0))
        let sut = IndexedContactMatching(factory: factory, settings: ContactMatchingSettingsFake(length: 0))

        _ = sut.match(for: URI(user: "any", host: "any", displayName: "any"))
        _ = sut.match(for: URI(user: "any", host: "any", displayName: "any"))

        XCTAssertEqual(factory.makeCallCount, 1)
    }

    func testCreatesIndexWithSignificantPhoneNumberLengthFromSettingsAsMaxPhoneNumberLength() {
        let length = 99
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndex(contacts: SimpleContacts([]), maxPhoneNumberLength: 0))
        let sut = IndexedContactMatching(factory: factory, settings: ContactMatchingSettingsFake(length: length))

        _ = sut.match(for: URI(user: "any", host: "any", displayName: "any"))

        XCTAssertTrue(factory.didCallMake)
        XCTAssertEqual(factory.invokedMaxPhoneNumberLength, length)
    }

    func testMatchesContactByEmail() {
        let contact = Contact(name: "John Smith", phones: [], emails: [Contact.Email(address: "user@company.com", label: "work")])
        let sut = IndexedContactMatching(
            factory: DefaultContactMatchingIndexFactory(contacts: SimpleContacts([contact])),
            settings: ContactMatchingSettingsFake(length: 10)
        )

        let result = sut.match(for: URI(user: "user", host: "company.com", displayName: "any-name"))

        XCTAssertEqual(result, MatchedContact(contact: contact, emailIndex: 0))
    }

    func testMatchesContactByPhoneNumber() {
        let contact = Contact(name: "John Smith", phones: [Contact.Phone(number: "0123456789", label: "home")], emails: [])
        let sut = IndexedContactMatching(
            factory: DefaultContactMatchingIndexFactory(contacts: SimpleContacts([contact])),
            settings: ContactMatchingSettingsFake(length: 10)
        )

        let result = sut.match(for: URI(user: contact.phones[0].number, host: "any-host", displayName: "any-name"))

        XCTAssertEqual(result, MatchedContact(contact: contact, phoneIndex: 0))
    }

    func testMatchesContactByLastDigitsOfThePhoneNumber() {
        let contact = Contact(name: "John Smith", phones: [Contact.Phone(number: "0123456789", label: "home")], emails: [])
        let settings = ContactMatchingSettingsFake(length: 7)
        let sut = IndexedContactMatching(
            factory: DefaultContactMatchingIndexFactory(contacts: SimpleContacts([contact])), settings: settings
        )

        let result = sut.match(for: URI(user: "3456789", host: "any-host", displayName: "any-name"))

        XCTAssertEqual(result, MatchedContact(contact: contact, phoneIndex: 0))
    }

    func testMatchesContactByEmailWhenBothEmailAndPhoneNumberExist() {
        let contact1 = Contact(name: "John Smith", phones: [], emails: [Contact.Email(address: "0123456789@company.com", label: "work")])
        let contact2 = Contact(name: "Jane Doe", phones: [Contact.Phone(number: "0123456789", label: "home")], emails: [])
        let sut = IndexedContactMatching(
            factory: DefaultContactMatchingIndexFactory(contacts: SimpleContacts([contact1, contact2])),
            settings: ContactMatchingSettingsFake(length: 10)
        )

        let result = sut.match(for: URI(user: "0123456789", host: "company.com", displayName: "any"))

        XCTAssertEqual(result, MatchedContact(contact: contact1, emailIndex: 0))
    }

    func testMatchesContactByPhoneNumberWhenContactPhoneContainsNonDigitCharacters() {
        let contact = Contact(name: "John Smith", phones: [Contact.Phone(number: "(012) 345-6789", label: "home")], emails: [])
        let sut = IndexedContactMatching(
            factory: DefaultContactMatchingIndexFactory(contacts: SimpleContacts([contact])),
            settings: ContactMatchingSettingsFake(length: 10)
        )

        let result = sut.match(for: URI(user: "0123456789", host: "any-host", displayName: "any-name"))

        XCTAssertEqual(result, MatchedContact(contact: contact, phoneIndex: 0))
    }

    func testMatchesContactByEmailWhenContactEmailContainsUppercaseCharacters() {
        let contact = Contact(name: "Jane", phones: [], emails: [Contact.Email(address: "JohnSmith@Company.com", label: "work")])
        let sut = IndexedContactMatching(
            factory: DefaultContactMatchingIndexFactory(contacts: SimpleContacts([contact])),
            settings: ContactMatchingSettingsFake(length: 0)
        )

        let result = sut.match(for: URI(user: "johnsmith", host: "Company.com", displayName: "any"))

        XCTAssertEqual(result, MatchedContact(contact: contact, emailIndex: 0))
    }

    func testReturnsNilWhenNothingIsFound() {
        let sut = IndexedContactMatching(
            factory: DefaultContactMatchingIndexFactory(
                contacts: SimpleContacts(
                    [
                        Contact(
                            name: "John Smith",
                            phones: [Contact.Phone(number: "0123456789", label: "home")],
                            emails: [Contact.Email(address: "user@company.com", label: "work")]
                        )
                    ]
                )
            ),
            settings: ContactMatchingSettingsFake(length: 0)
        )

        let result = sut.match(for: URI(user: "foo", host: "bar", displayName: ""))

        XCTAssertNil(result)
    }
}

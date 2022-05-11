//
//  SimpleContactMatchingIndexTests.swift
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

@testable import UseCases
import UseCasesTestDoubles
import XCTest

final class SimpleContactMatchingIndexTests: XCTestCase {
    func testFindsContactsByPhoneNumberAndEmailAddress() {
        let contact1 = makeContact(number: 1)
        let contact2 = makeContact(number: 2)
        let length = 20
        let sut = SimpleContactMatchingIndex(contacts: SimpleContacts([contact1, contact2]), maxPhoneNumberLength: length)

        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact1.phones[0].number, maxLength: length)), MatchedContact(contact: contact1, phoneIndex: 0))
        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact1.phones[1].number, maxLength: length)), MatchedContact(contact: contact1, phoneIndex: 1))
        XCTAssertEqual(sut.contact(forEmail: NormalizedLowercasedString(contact1.emails[0].address)), MatchedContact(contact: contact1, emailIndex: 0))
        XCTAssertEqual(sut.contact(forEmail: NormalizedLowercasedString(contact1.emails[1].address)), MatchedContact(contact: contact1, emailIndex: 1))

        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact2.phones[0].number, maxLength: length)), MatchedContact(contact: contact2, phoneIndex: 0))
        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact2.phones[1].number, maxLength: length)), MatchedContact(contact: contact2, phoneIndex: 1))
        XCTAssertEqual(sut.contact(forEmail: NormalizedLowercasedString(contact2.emails[0].address)), MatchedContact(contact: contact2, emailIndex: 0))
        XCTAssertEqual(sut.contact(forEmail: NormalizedLowercasedString(contact2.emails[1].address)), MatchedContact(contact: contact2, emailIndex: 1))
    }

    func testFindsContactsByLastDigitsOfThePhoneNumber() {
        let contact1 = makeContact(number: 1)
        let contact2 = makeContact(number: 2)
        let length = 7
        let sut = SimpleContactMatchingIndex(contacts: SimpleContacts([contact1, contact2]), maxPhoneNumberLength: length)

        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact1.phones[0].number, maxLength: length)), MatchedContact(contact: contact1, phoneIndex:0))
        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact1.phones[1].number, maxLength: length)), MatchedContact(contact: contact1, phoneIndex:1))
        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact2.phones[0].number, maxLength: length)), MatchedContact(contact: contact2, phoneIndex:0))
        XCTAssertEqual(sut.contact(forPhone: ExtractedPhoneNumber(contact2.phones[1].number, maxLength: length)), MatchedContact(contact: contact2, phoneIndex:1))
    }

    func testFindsContactsWithEmailAddressesContainingUppercaseCharacters() {
        let contact1 = Contact(name: "any", phones: [], emails: [Contact.Email(address: "FOO@bar.com", label: "any")])
        let contact2 = Contact(name: "any", phones: [], emails: [Contact.Email(address: "JohnSmith@Company.com", label: "any")])
        let sut = SimpleContactMatchingIndex(contacts: SimpleContacts([contact1, contact2]), maxPhoneNumberLength: 0)

        XCTAssertEqual(sut.contact(forEmail: NormalizedLowercasedString(contact1.emails[0].address)), MatchedContact(contact: contact1, emailIndex: 0))
        XCTAssertEqual(sut.contact(forEmail: NormalizedLowercasedString(contact2.emails[0].address)), MatchedContact(contact: contact2, emailIndex: 0))
    }

    func testIgnoresEmptyAddresses() {
        let contact = Contact(
            name: "any",
            phones: [Contact.Phone(number: "", label: "any")],
            emails: [Contact.Email(address: "", label: "any")]
        )
        let sut = SimpleContactMatchingIndex(contacts: SimpleContacts([contact]), maxPhoneNumberLength: 10)

        XCTAssertNil(sut.contact(forEmail: NormalizedLowercasedString("")))
    }
}

private func makeContact(number: Int) -> Contact {
    return Contact(name: "name-\(number)", phones: makePhones(number: number), emails: makeEmails(number: number))
}

private func makePhones(number: Int) -> [Contact.Phone] {
    return [
        Contact.Phone(number: "1234567891\(number)", label: "label-\(number)"),
        Contact.Phone(number: "9876543212\(number)", label: "label-\(number)")
    ]
}

private func makeEmails(number: Int) -> [Contact.Email] {
    return [
        Contact.Email(address: "foo\(number)@host", label: "label-\(number)"),
        Contact.Email(address: "bar\(number)@host", label: "label-\(number)")
    ]
}

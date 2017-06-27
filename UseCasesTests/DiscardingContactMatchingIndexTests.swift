//
//  DiscardingContactMatchingIndexTests.swift
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

@testable import UseCases
import UseCasesTestDoubles
import XCTest

final class DiscardingContactMatchingIndexTests: XCTestCase {
    func testReturnsMatchFromOriginOnSearchByPhone() {
        let contact = MatchedContact(name: "any-name", address: .phone(number: "any-number", label: "any-label"))
        let sut = DiscardingContactMatchingIndex(
            factory: ContactMatchingIndexFactoryStub(indexes: [ContactMatchingIndexStub(contact: contact)])
        )

        let result = sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))

        XCTAssertEqual(result, contact)
    }

    func testReturnsMatchFromOriginOnSearchByEmail() {
        let contact = MatchedContact(name: "any-name", address: .email(address: "any-address", label: "any-label"))
        let sut = DiscardingContactMatchingIndex(
            factory: ContactMatchingIndexFactoryStub(indexes: [ContactMatchingIndexStub(contact: contact)])
        )

        let result = sut.contact(forEmail: NormalizedLowercasedString("any"))

        XCTAssertEqual(result, contact)
    }

    func testReturnsMatchFromRecreatedOriginAfterContactsChangeEventOnSearchByPhone() {
        let contact = MatchedContact(name: "any-name-2", address: .phone(number: "any-number-2", label: "any-label-2"))
        let sut = DiscardingContactMatchingIndex(
            factory: ContactMatchingIndexFactoryStub(
                indexes: [
                    ContactMatchingIndexStub(
                        contact: MatchedContact(
                            name: "any-name-1", address: .phone(number: "any-number-1", label: "any-label-1")
                        )
                    ),
                    ContactMatchingIndexStub(contact: contact)
                ]
            )
        )

        sut.contactsDidChange()
        let result = sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))

        XCTAssertEqual(result, contact)
    }

    func testReturnsMatchFromRecreatedOriginAfterContactsChangeEventOnSearchByEmail() {
        let contact = MatchedContact(name: "any-name-2", address: .email(address: "any-address-2", label: "any-label-2"))
        let sut = DiscardingContactMatchingIndex(
            factory: ContactMatchingIndexFactoryStub(
                indexes: [
                    ContactMatchingIndexStub(
                        contact: MatchedContact(
                            name: "any-name-1", address: .email(address: "any-address-1", label: "any-label-1")
                        )
                    ),
                    ContactMatchingIndexStub(contact: contact)
                ]
            )
        )

        sut.contactsDidChange()
        let result = sut.contact(forEmail: NormalizedLowercasedString("any"))

        XCTAssertEqual(result, contact)
    }
}

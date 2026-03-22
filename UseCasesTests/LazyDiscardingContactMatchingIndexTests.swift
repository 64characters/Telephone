//
//  LazyDiscardingContactMatchingIndexTests.swift
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
@testable import UseCases
import UseCasesTestDoubles

@ContactsActor
struct LazyDiscardingContactMatchingIndexTests {
    @Test func doesNotCreateOriginOnCreation() {
        let factory = ContactMatchingIndexFactorySpy()

        _ = LazyDiscardingContactMatchingIndex(factory: factory)

        #expect(!factory.didCallMake)
    }

    @Test func createsOriginOnFirstSearchByPhone() async {
        let factory = ContactMatchingIndexFactorySpy()
        let sut = LazyDiscardingContactMatchingIndex(factory: factory)

        _ = await sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))

        #expect(factory.didCallMake)
    }

    @Test func createsOriginOnFirsthSearchByEmail() async {
        let factory = ContactMatchingIndexFactorySpy()
        let sut = LazyDiscardingContactMatchingIndex(factory: factory)

        _ = await sut.contact(forEmail: NormalizedLowercasedString("any"))

        #expect(factory.didCallMake)
    }

    @Test func createsOriginOnce() async {
        let factory = ContactMatchingIndexFactorySpy()
        let sut = LazyDiscardingContactMatchingIndex(factory: factory)

        _ = await sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 10))
        _ = await sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 10))
        _ = await sut.contact(forEmail: NormalizedLowercasedString("any"))
        _ = await sut.contact(forEmail: NormalizedLowercasedString("any"))

        #expect(factory.makeCallCount == 1)
    }

    @Test func returnsMatchFromOriginOnSearchByPhone() async {
        let contact = MatchedContact(name: "any-name", address: .phone(number: "any-number", label: "any-label"))
        let sut = LazyDiscardingContactMatchingIndex(
            factory: ContactMatchingIndexFactoryStub(indexes: [ContactMatchingIndexStub(contact: contact)])
        )

        let result = await sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))

        #expect(result == contact)
    }

    @Test func returnsMatchFromOriginOnSearchByEmail() async {
        let contact = MatchedContact(name: "any-name", address: .email(address: "any-address", label: "any-label"))
        let sut = LazyDiscardingContactMatchingIndex(
            factory: ContactMatchingIndexFactoryStub(indexes: [ContactMatchingIndexStub(contact: contact)])
        )

        let result = await sut.contact(forEmail: NormalizedLowercasedString("any"))

        #expect(result == contact)
    }

    @Test func doesNotCreateOriginOnContactsDidChange() {
        let factory = ContactMatchingIndexFactorySpy()
        let sut = LazyDiscardingContactMatchingIndex(factory: factory)

        sut.contactsDidChange()

        #expect(!factory.didCallMake)
    }

    @Test func returnsMatchFromRecreatedOriginAfterContactsChangeEventOnSearchByPhone() async {
        let contact = MatchedContact(name: "any-name-2", address: .phone(number: "any-number-2", label: "any-label-2"))
        let sut = LazyDiscardingContactMatchingIndex(
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

        _ = await sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))
        sut.contactsDidChange()
        let result = await sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))

        #expect(result == contact)
    }

    @Test func returnsMatchFromRecreatedOriginAfterContactsChangeEventOnSearchByEmail() async {
        let contact = MatchedContact(name: "any-name-2", address: .email(address: "any-address-2", label: "any-label-2"))
        let sut = LazyDiscardingContactMatchingIndex(
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

        _ = await sut.contact(forEmail: NormalizedLowercasedString("any"))
        sut.contactsDidChange()
        let result = await sut.contact(forEmail: NormalizedLowercasedString("any"))

        #expect(result == contact)
    }
}

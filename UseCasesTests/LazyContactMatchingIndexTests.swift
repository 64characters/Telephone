//
//  LazyContactMatchingIndexTests.swift
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
@testable import UseCases
import UseCasesTestDoubles

final class LazyContactMatchingIndexTests: XCTestCase {
    func testDoesNotCreateOriginOnCreation() {
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndexDummy())

        _ = LazyContactMatchingIndex(factory: factory, settings: ContactMatchingSettingsFake(length: 0))

        XCTAssertFalse(factory.didCallMake)
    }

    func testDoesNotGetSignificantPhoneNumberLengthFromSettingsOnCreation() {
        let settings = ContactMatchingSettingsSpy()

        _ = LazyContactMatchingIndex(
            factory: ContactMatchingIndexFactorySpy(index: ContactMatchingIndexDummy()), settings: settings
        )

        XCTAssertFalse(settings.didCallSignificantPhoneNumberLength)
    }

    func testCreatesOriginWithSignificantPhoneNumberLengthFromSettingsOnFirstSearchByPhone() {
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndexDummy())
        let length = 10
        let settings = ContactMatchingSettingsFake(length: length)
        let sut = LazyContactMatchingIndex(factory: factory, settings: settings)

        _ = sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))

        XCTAssertTrue(factory.didCallMake)
        XCTAssertEqual(factory.invokedMaxPhoneNumberLength, length)
    }

    func testCreatesOriginWithSignificantPhoneNumberLengthFromSettingsOnFirsthSearchByEmail() {
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndexDummy())
        let length = 10
        let sut = LazyContactMatchingIndex(factory: factory, settings: ContactMatchingSettingsFake(length: length))

        _ = sut.contact(forEmail: NormalizedLowercasedString("any"))

        XCTAssertTrue(factory.didCallMake)
        XCTAssertEqual(factory.invokedMaxPhoneNumberLength, length)
    }

    func testCreatesOriginOnce() {
        let factory = ContactMatchingIndexFactorySpy(index: ContactMatchingIndexDummy())
        let sut = LazyContactMatchingIndex(factory: factory, settings: ContactMatchingSettingsFake(length: 0))

        _ = sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 10))
        _ = sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 10))
        _ = sut.contact(forEmail: NormalizedLowercasedString("any"))
        _ = sut.contact(forEmail: NormalizedLowercasedString("any"))

        XCTAssertEqual(factory.makeCallCount, 1)
    }

    func testGetsSignificantPhoneNumberLengthFromSettingsOnce() {
        let settings = ContactMatchingSettingsSpy()
        let sut = LazyContactMatchingIndex(
            factory: ContactMatchingIndexFactorySpy(index: ContactMatchingIndexDummy()), settings: settings
        )

        _ = sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 10))
        _ = sut.contact(forEmail: NormalizedLowercasedString("any"))

        XCTAssertEqual(settings.significantPhoneNumberLengthCallCount, 1)
    }

    func testReturnsMatchFromOriginOnSearchByPhone() {
        let contact = MatchedContact(name: "any-name", address: .phone(number: "any-number", label: "any-label"))
        let sut = LazyContactMatchingIndex(
            factory: ContactMatchingIndexFactorySpy(index: ContactMatchingIndexStub(contact: contact)),
            settings: ContactMatchingSettingsFake(length: 0)
        )

        let result = sut.contact(forPhone: ExtractedPhoneNumber("any", maxLength: 0))

        XCTAssertEqual(result, contact)
    }

    func testReturnsMatchFromOriginOnSearchByEmail() {
        let contact = MatchedContact(name: "any-name", address: .email(address: "any-address", label: "any-label"))
        let sut = LazyContactMatchingIndex(
            factory: ContactMatchingIndexFactorySpy(index: ContactMatchingIndexStub(contact: contact)),
            settings: ContactMatchingSettingsFake(length: 0)
        )

        let result = sut.contact(forEmail: NormalizedLowercasedString("any"))

        XCTAssertEqual(result, contact)
    }
}

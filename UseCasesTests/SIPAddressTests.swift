//
//  SIPAddressTests.swift
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

import UseCases
import XCTest

final class SIPAddressTests: XCTestCase {
    func testCanCreateWithUserAndHost() {
        let sut = SIPAddress(user: "any-user", host: "any-host")

        XCTAssertEqual(sut.user, "any-user")
        XCTAssertEqual(sut.host, "any-host")
    }

    func testCanCreateWithTypeMethodWithUserAndHost() {
        let sut = SIPAddress.address(user: "any-user", host: "any-host")

        XCTAssertEqual(sut.user, "any-user")
        XCTAssertEqual(sut.host, "any-host")
    }

    func testUserIsSubstringBeforeAtCharacterAndHostIsSubstringAfterAtCharacterWhenCreatedWithString() {
        let sut = SIPAddress("user@host")

        XCTAssertEqual(sut.user, "user")
        XCTAssertEqual(sut.host, "host")
    }

    func testUserIsEmptyAndHostIsInputStringWhenInputStringDoesNotHaveAtCharacter() {
        let sut = SIPAddress("any")

        XCTAssertTrue(sut.user.isEmpty)
        XCTAssertEqual(sut.host, "any")
    }

    func testHostDoesNotContainSquareBracketsWhenHostIsAnIPv6Address() {
        XCTAssertEqual(SIPAddress(user: "any", host: "1:2:3:4:5:6:7:8").host, "1:2:3:4:5:6:7:8")
    }

    func testStringValue() {
        XCTAssertEqual(SIPAddress(user: "user", host: "host").stringValue, "user@host")
    }

    func testStringValueWhenHostIsAnIPv6Address() {
        XCTAssertEqual(SIPAddress(user: "any", host: "1:2:3:4:5:6:7:8").stringValue, "any@[1:2:3:4:5:6:7:8]")
    }

    func testStrinValueWhenUserIsEmpty() {
        XCTAssertEqual(SIPAddress(user: "", host: "host").stringValue, "host")
    }

    func testEquality() {
        XCTAssertEqual(SIPAddress(user: "any-user", host: "any-host"), SIPAddress(user: "any-user", host: "any-host"))
    }

    func testTextualRepresentationIsSameAsStringValue() {
        let sut = SIPAddress(user: "john", host: "example.com")

        XCTAssertEqual(String(describing: sut), sut.stringValue)
    }
}

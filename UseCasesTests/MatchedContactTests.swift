//
//  MatchedContactTests.swift
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

final class MatchedContactTests: XCTestCase {
    func testNameIsURIDisplayNameOnCreationFromURI() {
        let uri = URI(user: "any-user", host: "any-host", displayName: "any-name")

        let result = MatchedContact(uri: uri)

        XCTAssertEqual(result.name, uri.displayName)
    }

    func testAddressIsEmailComposedOfUserAndHostWhenHostIsNotEmptyOnCreationFromURI() {
        let uri = URI(user: "any-user", host: "any-host", displayName: "any-name")

        let result = MatchedContact(uri: uri)

        XCTAssertEqual(result.address, .email(address: "\(uri.user)@\(uri.host)", label:""))
    }

    func testAddressIsPhoneComposedOfUserWhenHostIsEmptyOnCreationFromURI() {
        let uri = URI(user: "any-user", host: "", displayName: "any-name")

        let result = MatchedContact(uri: uri)

        XCTAssertEqual(result.address, .phone(number: uri.user, label: ""))
    }
}

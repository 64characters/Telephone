//
//  URITests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2020 64 Characters
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

final class URITests: XCTestCase {
    func testTwoURIsWithTheSamePropertiesAreEqual() {
        XCTAssertEqual(
            URI(user: "any-user", host: "any-host", displayName: "any-name"),
            URI(user: "any-user", host: "any-host", displayName: "any-name")
        )
    }

    func testTextualRepresentationWithoutDisplayName() {
        XCTAssertEqual(
            String(describing: URI(user: "john", host: "example.com", displayName: "")), "<sip:john@example.com>"
        )
    }

    func testTextualRepresentationWithDisplayName() {
        XCTAssertEqual(
            String(describing: URI(user: "john", host: "example.com", displayName: "John Doe")),
            "\"John Doe\" <sip:john@example.com>"
        )
    }
}

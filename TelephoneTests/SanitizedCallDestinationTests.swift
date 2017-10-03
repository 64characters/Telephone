//
//  SanitizedCallDestinationTests.swift
//  TelephoneTests
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

final class SanitizedCallDestinationTests: XCTestCase {
    func testReturnsOriginalString() {
        XCTAssertEqual(SanitizedCallDestination("any").value, "any")
    }

    func testRemovesSlashesWhenBeginsWithSIP() {
        XCTAssertEqual(SanitizedCallDestination("sip://user@host").value, "sip:user@host")
    }

    func testRemovesSlashesWhenBeginsWithTel() {
        XCTAssertEqual(SanitizedCallDestination("tel://12345").value, "tel:12345")
    }

    func testRemovesHeaders() {
        XCTAssertEqual(SanitizedCallDestination("any?headers").value, "any")
    }

    func testRemovesHeadersFromSIPURI() {
        XCTAssertEqual(SanitizedCallDestination("sip:any?headers").value, "sip:any")
    }

    func testRemovesHeadersFromTelURI() {
        XCTAssertEqual(SanitizedCallDestination("tel:123?headers").value, "tel:123")
    }
}

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
    func testEquality() {
        XCTAssertEqual(
            URI(user: "any-user", host: "any-host", displayName: "any-name"),
            URI(user: "any-user", host: "any-host", displayName: "any-name")
        )
    }

    func testStringValueWhenDisplayNameAndPortAreNotSpecified() {
        XCTAssertEqual(
            URI(user: "john", host: "example.com", displayName: "").stringValue, "<sip:john@example.com>"
        )
    }

    func testStringValueWhenDisplayNameIsSpecifiedAndPortIsNotSpecified() {
        XCTAssertEqual(
            URI(user: "john", host: "example.com", displayName: "John Doe").stringValue,
            "\"John Doe\" <sip:john@example.com>"
        )
    }

    func testStringValueWhenPortIsSpecifiedAndDisplayNameIsNotSpecified() {
        XCTAssertEqual(URI(address: ServiceAddress(host: "any", port: "123")).stringValue, "<sip:any:123>")
    }

    func testStringValueWhenDisplayNameAndPortAreSpecified() {
        XCTAssertEqual(
            URI(user: "user", address: ServiceAddress(host: "host", port: "123"), displayName: "Name").stringValue,
            "\"Name\" <sip:user@host:123>"
        )
    }

    func testCanCreateWithServiceAddress() {
        let sut = URI(address: ServiceAddress(string: "any:123"))

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.port, "123")
    }

    func testCanCreateWithUserAndServiceAddressAndDisplayName() {
        let address = ServiceAddress(host: "host", port: "123")
        let sut = URI(user: "user", address: address, displayName: "Name")

        XCTAssertEqual(sut.user, "user")
        XCTAssertEqual(sut.address, address)
        XCTAssertEqual(sut.displayName, "Name")
    }

    func testHostAndPortAreHostAndPortFromAddress() {
        let sut = URI(address: ServiceAddress(host: "any", port: "1234"))

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.port, "1234")
    }
}

//
//  URITests.swift
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

final class URITests: XCTestCase {
    func testCanCreateWithUserAndServiceAddressAndDisplayNameAndTransport() {
        XCTAssertNotNil(
            URI(user: "any-user", address: ServiceAddress(host: "any-host"), displayName: "any-name", transport: .udp)
        )
    }

    func testEquality() {
        XCTAssertEqual(
            URI(user: "any-user", address: ServiceAddress(host: "any-host"), displayName: "any-name", transport: .tcp),
            URI(user: "any-user", address: ServiceAddress(host: "any-host"), displayName: "any-name", transport: .tcp)
        )
        XCTAssertNotEqual(
            URI(user: "any-user", address: ServiceAddress(host: "any-host"), displayName: "any-name", transport: .udp),
            URI(user: "any-user", address: ServiceAddress(host: "any-host"), displayName: "any-name", transport: .tcp)
        )
        XCTAssertEqual(
            URI(user: "any-user", host: "any-host", displayName: "any-name"),
            URI(user: "any-user", host: "any-host", displayName: "any-name")
        )
    }

    func testStringValueWhenDisplayNameAndPortAreNotSpecified() {
        XCTAssertEqual(
            URI(user: "john", host: "example.com", displayName: "").stringValue, "sip:john@example.com"
        )
    }

    func testStringValueWhenDisplayNameIsSpecifiedAndPortIsNotSpecified() {
        XCTAssertEqual(
            URI(user: "john", host: "example.com", displayName: "John Doe").stringValue,
            "\"John Doe\" <sip:john@example.com>"
        )
    }

    func testStringValueWhenPortIsSpecifiedAndDisplayNameIsNotSpecified() {
        XCTAssertEqual(URI(address: ServiceAddress(host: "any", port: "123")).stringValue, "sip:any:123")
    }

    func testStringValueWhenDisplayNameAndPortAreSpecified() {
        XCTAssertEqual(
            URI(user: "user", address: ServiceAddress(host: "host", port: "123"), displayName: "Name").stringValue,
            "\"Name\" <sip:user@host:123>"
        )
    }

    func testStringValueWithUserAndHostAndPortAndDisplayNameAndTCPTransport() {
        XCTAssertEqual(
            URI(user: "user", address: ServiceAddress(host: "host", port: "123"), displayName: "Name", transport: .tcp).stringValue,
            "\"Name\" <sip:user@host:123;transport=tcp>"
        )
    }

    func testStringValueDoesNotContainTransportWhenTransportIsUDP() {
        XCTAssertEqual(
            URI(user: "user", address: ServiceAddress(host: "host"), displayName: "", transport: .udp).stringValue,
            "sip:user@host"
        )
    }

    func testStringValueContainsTransportTCPWhenTransportIsTCP() {
        XCTAssertEqual(
            URI(user: "user", address: ServiceAddress(host: "host"), displayName: "", transport: .tcp).stringValue,
            "sip:user@host;transport=tcp"
        )
    }

    func testStringValueContainsTransportTLSWhenTransportIsTLS() {
        XCTAssertEqual(
            URI(user: "user", address: ServiceAddress(host: "host"), displayName: "", transport: .tls).stringValue,
            "sip:user@host;transport=tls"
        )
    }

    func testCanCreateWithServiceAddress() {
        let sut = URI(address: ServiceAddress("any:123"))

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

    func testCanCreateWithHostAndPort() {
        let sut = URI(host: "any", port: "123")

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.port, "123")
    }

    func testCanCreateWithHost() {
        XCTAssertEqual(URI(host: "any").host, "any")
    }

    func testCanCreateWithTypeMethodWithHostAndPortAndTransport() {
        let sut = URI.uri(host: "any", port: "123", transport: .tls)

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.port, "123")
        XCTAssertEqual(sut.transport, .tls)
    }

    func testCanCreateWithTypeMethodWithHostAndTransport() {
        let sut = URI.uri(host: "any", transport: .tcp)

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.transport, .tcp)
    }

    func testTextualRepresentationIsSameAsStringValue() {
        let sut = URI(user: "user", address: ServiceAddress(host: "host", port: "123"), displayName: "Name")

        XCTAssertEqual(String(describing: sut), sut.stringValue)
    }

    // MARK: - Creation from string

    func testCanCreateWithStringWithFullName() {
        XCTAssertEqual(URI("Full Name <sip:user@host>"), URI(user: "user", host: "host", displayName: "Full Name"))
    }

    func testCanCreateWithStringWithFullNameWithoutTrailingSpace() {
        XCTAssertEqual(URI("Full Name<sip:user@host>"), URI(user: "user", host: "host", displayName: "Full Name"))
    }

    func testCanCreateWithStringWhenFullNameIsInQuotes() {
        XCTAssertEqual(URI("\"Full Name\" <sip:user@host>"), URI(user: "user", host: "host", displayName: "Full Name"))
    }

    func testCanCreateWithStringWhenFullNameIsInQuotesWithoutTrailingSpace() {
        XCTAssertEqual(URI("\"Full Name\"<sip:user@host>"), URI(user: "user", host: "host", displayName: "Full Name"))
    }

    func testCanCreateWithStringWithFullNameWithoutUser() {
        XCTAssertEqual(URI("Full Name <sip:host>"), URI(user: "", host: "host", displayName: "Full Name"))
    }

    func testCanCreateWithStringWithoutFullName() {
        XCTAssertEqual(URI("sip:user@host"), URI(user: "user", host: "host", displayName: ""))
    }

    func testCanCreateWithStringWithTelScheme() {
        XCTAssertEqual(URI("tel:any"), URI(user: "any", host: "", displayName: ""))
    }

    func testCanCreateWithStringWhenSchemeIsNotLowercased() {
        XCTAssertEqual(URI("SiP:user@host"), URI(user: "user", host: "host", displayName: ""))
    }
}

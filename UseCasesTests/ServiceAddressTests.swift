//
//  ServiceAddressTests.swift
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

final class ServiceAddressTests: XCTestCase {
    func testHostIsCompleteInputStringWhenNoPortIsSpecified() {
        XCTAssertEqual(ServiceAddress("any").host, "any")
    }

    func testHostIsSubstringBeforeColon() {
        XCTAssertEqual(ServiceAddress("any:123").host, "any")
    }

    func testPortIsSubstringAfterColon() {
        XCTAssertEqual(ServiceAddress("any:123").port, "123")
    }

    func testPortIsEmptyStringWhenInputStringEndsWithColon() {
        XCTAssertEqual(ServiceAddress("any:").port, "")
    }

    func testSubstringAfterSemicolonIsIgnoredWhenNoPortIsSpecified() {
        XCTAssertEqual(ServiceAddress("any;params").host, "any")
    }

    func testSubstringAfterSemicolonIsIgnoredWhenPortIsSpecified() {
        let sut = ServiceAddress("any:123;params")

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.port, "123")
    }

    func testSquareBracketsAreIgnoredWhenPortIsNotSpecified() {
        XCTAssertEqual(ServiceAddress("[any]").host, "any")
    }

    func testSquareBracketsAreIgnoredWhenPortIsSpecified() {
        let sut = ServiceAddress("[any]:123")

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.port, "123")
    }

    func testSquareBracketsAreIgnoredWhenHostIsAnIPv6AddressAndPortIsSpecified() {
        let sut = ServiceAddress("[1:2:3:4:5:6:7:8]:123")

        XCTAssertEqual(sut.host, "1:2:3:4:5:6:7:8")
        XCTAssertEqual(sut.port, "123")
    }

    func testHostIsCompleteInputStringWhenInputStringIsAnIPv6Address() {
        XCTAssertEqual(ServiceAddress("1:2:3:4:5:6:7:8").host, "1:2:3:4:5:6:7:8")
    }

    func testHostIsSubstringInsideSquareBracketsWhenItContainsColonsAndPortIsNotSpecified() {
        XCTAssertEqual(ServiceAddress("[1:2:3:4:5:6:7:8]").host, "1:2:3:4:5:6:7:8")
    }

    func testCanCreateWithHostAndPort() {
        let sut = ServiceAddress(host: "any", port: "123")

        XCTAssertEqual(sut.host, "any")
        XCTAssertEqual(sut.port, "123")
    }

    func testSquareBracketsAreIgnoredWhenCreatedWithHost() {
        XCTAssertEqual(ServiceAddress(host: "[any]", port: "").host, "any")
    }

    func testStringValueWhenHostIsSpecifiedAndPortIsNotSpecified() {
        XCTAssertEqual(ServiceAddress(host: "any").stringValue, "any")
    }

    func testStringValueWhenHostAndPortAreSpecified() {
        XCTAssertEqual(ServiceAddress(host: "any", port: "123").stringValue, "any:123")
    }

    func testStringValueWhenHostIsAnIPv6AddressAndPortIsNotSpecified() {
        XCTAssertEqual(ServiceAddress(host: "1:2:3:4:5:6:7:8").stringValue, "[1:2:3:4:5:6:7:8]")
    }

    func testStringValueWhenHostIsAnIPv6AddressAndPortIsSpecified() {
        XCTAssertEqual(ServiceAddress(host: "1:2:3:4:5:6:7:8", port: "123").stringValue, "[1:2:3:4:5:6:7:8]:123")
    }

    func testEquality() {
        XCTAssertEqual(ServiceAddress(host: "any", port: "123"), ServiceAddress(host: "any", port: "123"))
    }

    func testTextualRepresentationIsSameAsStringValue() {
        let sut = ServiceAddress(host: "host", port: "1337")

        XCTAssertEqual(String(describing: sut), sut.stringValue)
    }
}

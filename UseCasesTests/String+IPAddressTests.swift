//
//  String+IPAddressTests.swift
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

final class String_IPAddressTests: XCTestCase {
    func testIsIPAddressIsTrueIfStringIsEitherAnIPv4OrIPv6Address() {
        XCTAssertTrue("192.168.0.1".isIPAddress)
        XCTAssertTrue("1:2:3:4:5:6:7:8".isIPAddress)
    }

    func testIsIPAddressIsFalseIfStringIsNeitherAnIPv4NorIPv6Address() {
        XCTAssertFalse("1.1.1.1.1".isIPAddress)
        XCTAssertFalse("1:2:3:4:5:6:7:8:9".isIPAddress)
        XCTAssertFalse("foo".isIPAddress)
    }

    func testIsIP4AddressIsTrueIfStringIsAnIPv4Address() {
        XCTAssertTrue("192.168.0.1".isIP4Address)
        XCTAssertTrue("0.0.0.0".isIP4Address)
    }

    func testIsIP4AddressIsFalseIfStringIsNotAnIPv4Address() {
        XCTAssertFalse("any".isIP4Address)
        XCTAssertFalse("a.b.c.d".isIP4Address)
        XCTAssertFalse("1.1.1.1.1".isIP4Address)
        XCTAssertFalse("1.1.1.a".isIP4Address)
        XCTAssertFalse("1.1.1.1a".isIP4Address)
        XCTAssertFalse("@1.1.1.1".isIP4Address)
        XCTAssertFalse(" 1.1.1.1".isIP4Address)
        XCTAssertFalse("1.1.1.1 ".isIP4Address)
        XCTAssertFalse("192.168.000.001".isIP4Address)
        XCTAssertFalse("1:2:3:4:5:6:7:8".isIP4Address)
        XCTAssertFalse("::255.255.255.255".isIP4Address)
        XCTAssertFalse("2001:db8:3:4::192.0.2.33".isIP4Address)
    }

    func testIsIP6AddressIsTrueIfStringIsAnIPv6Address() {
        XCTAssertTrue("1:2:3:4:5:6:7:8".isIP6Address)
        XCTAssertTrue("1::".isIP6Address)
        XCTAssertTrue("1::8".isIP6Address)
        XCTAssertTrue("1::7:8".isIP6Address)
        XCTAssertTrue("1::6:7:8".isIP6Address)
        XCTAssertTrue("1::5:6:7:8".isIP6Address)
        XCTAssertTrue("1::4:5:6:7:8".isIP6Address)
        XCTAssertTrue("1::3:4:5:6:7:8".isIP6Address)
        XCTAssertTrue("::2:3:4:5:6:7:8".isIP6Address)
        XCTAssertTrue("1:2:3:4:5:6:7::".isIP6Address)
        XCTAssertTrue("1:2:3:4:5:6::8".isIP6Address)
        XCTAssertTrue("1:2:3:4:5::7:8".isIP6Address)
        XCTAssertTrue("1:2:3:4:5::8".isIP6Address)
        XCTAssertTrue("1:2:3:4::6:7:8".isIP6Address)
        XCTAssertTrue("1:2:3:4::8".isIP6Address)
        XCTAssertTrue("1:2:3::5:6:7:8".isIP6Address)
        XCTAssertTrue("1:2::4:5:6:7:8".isIP6Address)
        XCTAssertTrue("1::3:4:5:6:7:8".isIP6Address)
        XCTAssertTrue("::2:3:4:5:6:7:8".isIP6Address)
        XCTAssertTrue("1:2:3:4:5::8".isIP6Address)
        XCTAssertTrue("1:2:3:4::8".isIP6Address)
        XCTAssertTrue("1:2:3::8".isIP6Address)
        XCTAssertTrue("1:2::8".isIP6Address)
        XCTAssertTrue("1::8".isIP6Address)
        XCTAssertTrue("::8".isIP6Address)
        XCTAssertTrue("::".isIP6Address)
        XCTAssertTrue("fe80::7:8%eth0".isIP6Address)
        XCTAssertTrue("fe80::7:8%1".isIP6Address)
        XCTAssertTrue("::255.255.255.255".isIP6Address)
        XCTAssertTrue("::ffff:255.255.255.255".isIP6Address)
        XCTAssertTrue("::ffff:0:255.255.255.255".isIP6Address)
        XCTAssertTrue("2001:db8:3:4::192.0.2.33".isIP6Address)
        XCTAssertTrue("64:ff9b::192.0.2.33".isIP6Address)
        XCTAssertTrue("2001:db8::".isIP6Address)
    }

    func testIsIP6AddressIsFalseIfStringIsNotAnIPv6Address() {
        XCTAssertFalse("".isIP6Address)
        XCTAssertFalse("1".isIP6Address)
        XCTAssertFalse("192.168.1.1".isIP6Address)
        XCTAssertFalse("a".isIP6Address)
        XCTAssertFalse("1:2:3:4:5:6:7:8foo".isIP6Address)
        XCTAssertFalse("1:2:3:4:5:6:7:8 ".isIP6Address)
        XCTAssertFalse(" 1:2:3:4:5:6:7:8".isIP6Address)
    }
}

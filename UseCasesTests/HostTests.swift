//
//  HostTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

class HostTests: XCTestCase {
    func testCanCreate() {
        let sut = Host(string: "any")

        XCTAssertNotNil(sut)
    }

    func testAddressIsFullSourceStringWhenNoPortIsSpecified() {
        let sut = Host(string: "any")

        XCTAssertEqual(sut.address, "any")
    }

    func testAddressIsSubstringBeforeColon() {
        let sut = Host(string: "any:123")

        XCTAssertEqual(sut.address, "any")
    }

    func testPortIsSubstringAfterColon() {
        let sut = Host(string: "any:123")

        XCTAssertEqual(sut.port, "123")
    }

    func testPortIsEmptyStringWhenSourceStringEndsWithColon() {
        let sut = Host(string: "any:")

        XCTAssertEqual(sut.port, "")
    }
}

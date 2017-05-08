//
//  NormalizedPhoneNumberTests.swift
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
import UseCases

final class NormalizedPhoneNumberTests: XCTestCase {
    func testReturnsOriginalNumber() {
        let sut = NormalizedPhoneNumber("1234567", maxLength: 100)

        XCTAssertEqual(sut.value, "1234567")
    }

    func testReturnsNumberBeforeColon() {
        let sut = NormalizedPhoneNumber("12345,1234", maxLength: 100)

        XCTAssertEqual(sut.value, "12345")
    }

    func testReturnsNumberBeforeSemicolon() {
        let sut = NormalizedPhoneNumber("12345;1234", maxLength: 100)

        XCTAssertEqual(sut.value, "12345")
    }

    func testStripsNonNumericCharacters() {
        let sut = NormalizedPhoneNumber("xy+1 (234) 567-89;123 abc", maxLength: 100)

        XCTAssertEqual(sut.value, "123456789")
    }

    func testReturnsMaxLengthNumberOfDigitsFromTheEnd() {
        let sut = NormalizedPhoneNumber("98761 23456789012", maxLength: 12)

        XCTAssertEqual(sut.value, "123456789012")
    }
}

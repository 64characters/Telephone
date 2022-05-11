//
//  AKNSString+ScanningTests.swift
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

import XCTest

final class AKNSString_ScanningTests: XCTestCase {
    func testHasLettersIsTrueIfStringContainsAtLeastOneLetter() {
        XCTAssertTrue("a".ak_hasLetters)
        XCTAssertTrue("123b".ak_hasLetters)
        XCTAssertTrue("c456".ak_hasLetters)
        XCTAssertTrue("100d100".ak_hasLetters)
    }

    func testHasLettersIsFalseIfStringDoesNotContainAtLeastOneLetter() {
        XCTAssertFalse("1".ak_hasLetters)
        XCTAssertFalse("12345@_.,;#&".ak_hasLetters)
    }
}

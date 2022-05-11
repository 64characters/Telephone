//
//  ArrayDifferenceTests.swift
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

final class ArrayDifferenceTests: XCTestCase {
    func testIsPrependedWhenAfterEndsWithBefore() {
        if case .prepended(count: _) = ArrayDifference(before: Array(3...10), after: Array(1...10)) {
        } else {
            XCTFail()
        }
    }

    func testIsPrependedAndCountIsDifferenceBetweenAfterAndBeforeCount() {
        let before = Array(5...10)
        let after = Array(1...10)

        if case .prepended(count: let count) = ArrayDifference(before: before, after: after), count == after.count - before.count {
        } else {
            XCTFail()
        }
    }

    func testIsShiftedByOneWhenAfterIsBeforePlusOneItemInTheBeginningAndMinusOneItemInTheEnd() {
        if case .shiftedByOne = ArrayDifference(before: Array(2...10), after: Array(1...9)) {
        } else {
            XCTFail()
        }
    }

    func testIsOtherWhenBeforeIsEmpty() {
        if case .other = ArrayDifference(before: Array(), after: Array(1...5)) {
        } else {
            XCTFail()
        }
    }

    func testIsOtherWhenAfterIsEmpty() {
        if case .other = ArrayDifference(before: Array(1...10), after: Array()) {
        } else {
            XCTFail()
        }
    }

    func testIsOtherWhenAfterDoesNotEndWithBefore() {
        if case .other = ArrayDifference(before: Array(3...5), after: Array(1...4)) {
        } else {
            XCTFail()
        }
    }

    func testIsOtherWhenAfterIsBeforePlusTwoItemsInTheBeginningAndTwoItemsRemovedFromTheEnd() {
        if case .other = ArrayDifference(before: Array(2...10), after: Array(0...8)) {
        } else {
            XCTFail()
        }
    }
}

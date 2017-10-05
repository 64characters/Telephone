//
//  ArrayDifferenceTests.swift
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

final class ArrayDifferenceTests: XCTestCase {
    func testIsPrependedWhenAfterEndsWithBefore() {
        let sut = ArrayDifference(before: Array(3...10), after: Array(1...10))

        XCTAssertTrue(sut.isPrepended)
    }

    func testIsNotPrependedWhenAfterDoesNotEndWithBefore() {
        let sut = ArrayDifference(before: Array(3...5), after: Array(1...4))

        XCTAssertFalse(sut.isPrepended)
    }

    func testIsNotPrependedWhenBeforeIsEmpty() {
        let sut = ArrayDifference(before: Array(), after: Array(1...5))

        XCTAssertFalse(sut.isPrepended)
    }

    func testIsShiftedByOneWhenAfterIsBeforePlusOneItemInTheBeginningAndOneItemRemovedFromTheEnd() {
        let sut = ArrayDifference(before: Array(2...10), after: Array(1...9))

        XCTAssertTrue(sut.isShiftedByOne)
    }

    func testIsNotShiftedByOneWhenAfterIsBeforePlusTwoItemsInTheBeginningAndTwoItemsRemovedFromTheEnd() {
        let sut = ArrayDifference(before: Array(2...10), after: Array(0...8))

        XCTAssertFalse(sut.isShiftedByOne)
    }

    func testIsNotShiftedByOneWhenBeforeIsEmpty() {
        let sut = ArrayDifference(before: Array(), after: Array(1...5))

        XCTAssertFalse(sut.isShiftedByOne)
    }

    func testCountIsDifferenceBetweenAfterAndBeforeCount() {
        let before = Array(1...5)
        let after = Array(1...10)

        let sut = ArrayDifference(before: before, after: after)

        XCTAssertEqual(sut.count, after.count - before.count)
    }
}

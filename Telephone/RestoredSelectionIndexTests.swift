//
//  RestoredSelectionIndexTests.swift
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

final class RestoredSelectionIndexTests: XCTestCase {
    func testValueIsZeroWhenIndexBeforeIsMinusOne() {
        let sut = RestoredSelectionIndex(indexBefore: -1, before: Array(1...5), after: Array(1...5))

        XCTAssertEqual(sut.value, 0)
    }

    func testValueIsZeroWhenAfterIsEmpty() {
        let sut = RestoredSelectionIndex(indexBefore: 4, before: Array(1...5), after: Array<Int>())

        XCTAssertEqual(sut.value, 0)
    }

    func testValueIsIndexBeforePlusDifferenceBetweenBeforeAndAfterCountWhenAfterEndsWithBefore() {
        let indexBefore = 3
        let before = Array(5...10)
        let after = Array(1...10)

        let sut = RestoredSelectionIndex(indexBefore: indexBefore, before: before, after: after)

        XCTAssertEqual(sut.value, indexBefore + after.count - before.count)
    }

    func testValueIsIndexBeforeWhenIndexBeforeIsWithinAfter() {
        let indexBefore = 2

        let sut = RestoredSelectionIndex(indexBefore: indexBefore, before: Array(1...5), after: Array(1...3))

        XCTAssertEqual(sut.value, indexBefore)
    }

    func testValueIsLastIndexOfAfterWhenIndexBeforeIsOutsideOfAfter() {
        let after = Array(1...4)
        let sut = RestoredSelectionIndex(indexBefore: 4, before: Array(1...5), after: after)

        XCTAssertEqual(sut.value, after.endIndex - 1)
    }
}

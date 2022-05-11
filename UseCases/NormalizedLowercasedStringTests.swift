//
//  NormalizedLowercasedStringTests.swift
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

@testable import UseCases
import XCTest

final class NormalizedLowercasedStringTests: XCTestCase {
    func testValueIsOrigin() {
        let sut = NormalizedLowercasedString("foobar")

        XCTAssertEqual(sut.value, "foobar")
    }

    func testValueIsLowercasedOrigin() {
        let sut = NormalizedLowercasedString("StringWithCapitalLetters")

        XCTAssertEqual(sut.value, "stringwithcapitalletters")
    }

    func testValueEqualsToDecomposedOriginWhenOriginIsPrecomposed() {
        let sut = NormalizedLowercasedString(precomposed)

        XCTAssertEqual(sut.value, decomposed)
    }

    func testValueEqualsToPrecomposedOriginWhenOriginIsDecomposed() {
        let sut = NormalizedLowercasedString(decomposed)

        XCTAssertEqual(sut.value, precomposed)
    }

    func testValueEqualsToPrecomposedWhenOriginIsPrecomposed() {
        let sut = NormalizedLowercasedString(precomposed)

        XCTAssertEqual(sut.value, precomposed)
    }

    func testValueEqualsToDecomposedWhenOriginIsDecomposed() {
        let sut = NormalizedLowercasedString(decomposed)

        XCTAssertEqual(sut.value, decomposed)
    }
}

private let precomposed = "\u{E9}"  // é
private let decomposed = "\u{65}\u{301}"  // e followed by ´

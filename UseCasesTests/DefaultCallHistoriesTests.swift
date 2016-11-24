//
//  DefaultCallHistoriesTests.swift
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

import XCTest
import UseCases
import UseCasesTestDoubles

final class DefaultCallHistoriesTests: XCTestCase {
    func testCanSetHistory() {
        let history = TruncatingCallHistory()
        let sut = DefaultCallHistories()

        sut.set(history, forAccountWithID: "any")

        XCTAssertTrue(sut.history(forAccountWithID: "any") as! TruncatingCallHistory === history)
    }

    func testCanRemoveHistory() {
        let history = TruncatingCallHistory()
        let sut = DefaultCallHistories()

        sut.set(history, forAccountWithID: "any")
        sut.remove(historyForAccountWithID: "any")

        XCTAssertTrue(sut.history(forAccountWithID: "any") as? NullCallHistory != nil)
    }
}

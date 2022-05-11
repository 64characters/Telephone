//
//  FallingBackMatchedContactFactoryTests.swift
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
import UseCases
import UseCasesTestDoubles

final class FallingBackMatchedContactFactoryTests: XCTestCase {
    func testResultIsCreatedFromURIWhenMatchIsNotFound() {
        let sut = FallingBackMatchedContactFactory(matching: ContactMatchingStub([:]))
        let uri = URI(user: "any-user", host: "any-host", displayName: "any-name")

        let result = sut.make(uri: uri)

        XCTAssertEqual(result, MatchedContact(uri: uri))
    }

    func testResultIsMatchedContactWhenMatchIsFound() {
        let uri = URI(user: "any-user", host: "any-host", displayName: "any-name")
        let contact = MatchedContact(name: "other-name", address: .email(address: "any-address", label: "any-label"))
        let sut = FallingBackMatchedContactFactory(matching: ContactMatchingStub([uri: contact]))

        let result = sut.make(uri: uri)

        XCTAssertEqual(result, contact)
    }
}

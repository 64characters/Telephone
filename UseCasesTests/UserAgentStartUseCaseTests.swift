//
//  UserAgentStartUseCaseTests.swift
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
import UseCasesTestDoubles
import XCTest

final class UserAgentStartUseCaseTests: XCTestCase {
    func testSetsMaxCallsToThirtyAndStartsUserAgentWhenReceiptIsValid() {
        let agent = UserAgentSpy()
        let sut = UserAgentStartUseCase(agent: agent, factory: PurchaseCheckUseCaseFactory(receipt: ValidReceipt()))

        sut.execute()

        XCTAssertEqual(agent.maxCalls, 30)
        XCTAssertTrue(agent.didCallStart)
    }

    func testSetsMaxCallsToThreeAndStartsUserAgentWhenReceiptIsInvalid() {
        let agent = UserAgentSpy()
        let sut = UserAgentStartUseCase(agent: agent, factory: PurchaseCheckUseCaseFactory(receipt: InvalidReceipt()))

        sut.execute()

        XCTAssertEqual(agent.maxCalls, 3)
        XCTAssertTrue(agent.didCallStart)
    }
}

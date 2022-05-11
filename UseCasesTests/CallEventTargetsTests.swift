//
//  CallEventTargetsTests.swift
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

final class CallEventTargetsTests: XCTestCase {
    func testCallsDidMakeWithPassedArgumentOnAllTargets() {
        let first = CallEventTargetSpy()
        let second = CallEventTargetSpy()
        let call = CallTestFactory().make()
        let sut = CallEventTargets(targets: [first, second])

        sut.didMake(call)

        XCTAssertTrue(first.didCallDidMake)
        XCTAssertTrue(second.didCallDidMake)
        XCTAssertTrue(first.invokedCall === call)
        XCTAssertTrue(second.invokedCall === call)
    }

    func testCallsDidReceiveWithPassedArgumentOnAllTargets() {
        let first = CallEventTargetSpy()
        let second = CallEventTargetSpy()
        let call = CallTestFactory().make()
        let sut = CallEventTargets(targets: [first, second])

        sut.didReceive(call)

        XCTAssertTrue(first.didCallDidReceive)
        XCTAssertTrue(second.didCallDidReceive)
        XCTAssertTrue(first.invokedCall === call)
        XCTAssertTrue(second.invokedCall === call)
    }

    func testCallsIsConnectingWithPassedArgumentOnAllTargets() {
        let first = CallEventTargetSpy()
        let second = CallEventTargetSpy()
        let call = CallTestFactory().make()
        let sut = CallEventTargets(targets: [first, second])

        sut.isConnecting(call)

        XCTAssertTrue(first.didCallIsConnecting)
        XCTAssertTrue(second.didCallIsConnecting)
        XCTAssertTrue(first.invokedCall === call)
        XCTAssertTrue(second.invokedCall === call)
    }

    func testCallsDidDisconnectWithPassedArgumentOnAllTargets() {
        let first = CallEventTargetSpy()
        let second = CallEventTargetSpy()
        let call = CallTestFactory().make()
        let sut = CallEventTargets(targets: [first, second])

        sut.didDisconnect(call)

        XCTAssertTrue(first.didCallDidDisconnect)
        XCTAssertTrue(second.didCallDidDisconnect)
        XCTAssertTrue(first.invokedCall === call)
        XCTAssertTrue(second.invokedCall === call)
    }
}

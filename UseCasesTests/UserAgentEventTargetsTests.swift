//
//  UserAgentEventTargetsTests.swift
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

final class UserAgentEventTargetsTests: XCTestCase {
    private var sut: UserAgentEventTargets!
    private var target1: UserAgentEventTargetSpy!
    private var target2: UserAgentEventTargetSpy!
    private var agent: UserAgentSpy!

    override func setUp() {
        super.setUp()
        target1 = UserAgentEventTargetSpy()
        target2 = UserAgentEventTargetSpy()
        sut = UserAgentEventTargets(targets: [target1, target2])
        agent = UserAgentSpy()
    }

    func testCallsDidFinishStartingOnAllChildren() {
        sut.didFinishStarting(agent)

        XCTAssertTrue(target1.didCallDidFinishStarting)
        XCTAssertTrue(target2.didCallDidFinishStarting)
        assertUserAgent()
    }

    func testCallsDidFinishStoppingOnAllChildren() {
        sut.didFinishStopping(agent)

        XCTAssertTrue(target1.didCallDidFinishStopping)
        XCTAssertTrue(target2.didCallDidFinishStopping)
        assertUserAgent()
    }

    func testCallsDidDetectNATOnAllChildren() {
        sut.didDetectNAT(agent)

        XCTAssertTrue(target1.didCallDidDetectNAT)
        XCTAssertTrue(target2.didCallDidDetectNAT)
        assertUserAgent()
    }

    func testCallsDidMakeCallOnAllChildren() {
        sut.didMakeCall(agent)

        XCTAssertTrue(target1.didCallDidMakeCall)
        XCTAssertTrue(target2.didCallDidMakeCall)
        assertUserAgent()
    }

    func testCallsDidReceiveCallOnAllChildren() {
        sut.didReceiveCall(agent)

        XCTAssertTrue(target1.didCallDidReceiveCall)
        XCTAssertTrue(target2.didCallDidReceiveCall)
        assertUserAgent()
    }

    private func assertUserAgent() {
        XCTAssertTrue(target1.lastPassedAgent === agent)
        XCTAssertTrue(target2.lastPassedAgent === agent)
    }
}

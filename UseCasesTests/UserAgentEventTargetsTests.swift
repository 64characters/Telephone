//
//  UserAgentEventTargetsTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

class UserAgentEventTargetsTests: XCTestCase {
    private var sut: UserAgentEventTargets!
    private var target1: UserAgentEventTargetSpy!
    private var target2: UserAgentEventTargetSpy!
    private var userAgent: UserAgentSpy!

    override func setUp() {
        super.setUp()
        target1 = UserAgentEventTargetSpy()
        target2 = UserAgentEventTargetSpy()
        sut = UserAgentEventTargets(targets: [target1, target2])
        userAgent = UserAgentSpy()
    }

    func testCallsDidFinishStartingOnAllChildren() {
        sut.userAgentDidFinishStarting(userAgent)

        XCTAssertTrue(target1.didCallUserAgentDidFinishStarting)
        XCTAssertTrue(target2.didCallUserAgentDidFinishStarting)
        assertUserAgent()
    }

    func testCallsDidFinishStoppingOnAllChildren() {
        sut.userAgentDidFinishStopping(userAgent)

        XCTAssertTrue(target1.didCallUserAgentDidFinishStopping)
        XCTAssertTrue(target2.didCallUserAgentDidFinishStopping)
        assertUserAgent()
    }

    func testCallsDidDetectNATOnAllChildren() {
        sut.userAgentDidDetectNAT(userAgent)

        XCTAssertTrue(target1.didCallUserAgentDidDetectNAT)
        XCTAssertTrue(target2.didCallUserAgentDidDetectNAT)
        assertUserAgent()
    }

    func testCallsDidMakeCallOnAllChildren() {
        sut.userAgentDidMakeCall(userAgent)

        XCTAssertTrue(target1.didCallDidMakeCall)
        XCTAssertTrue(target2.didCallDidMakeCall)
        assertUserAgent()
    }

    func testCallsDidReceiveCallOnAllChildren() {
        sut.userAgentDidReceiveCall(userAgent)

        XCTAssertTrue(target1.didCallDidReceiveCall)
        XCTAssertTrue(target2.didCallDidReceiveCall)
        assertUserAgent()
    }

    private func assertUserAgent() {
        XCTAssertTrue(target1.lastPassedUserAgent === userAgent)
        XCTAssertTrue(target2.lastPassedUserAgent === userAgent)
    }
}

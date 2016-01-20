//
//  UserAgentObserverCompositeTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

class UserAgentObserverCompositeTests: XCTestCase {
    private var sut: UserAgentObserverComposite!
    private var observer1: UserAgentObserverSpy!
    private var observer2: UserAgentObserverSpy!
    private var userAgentDummy: UserAgentSpy!

    override func setUp() {
        super.setUp()
        observer1 = UserAgentObserverSpy()
        observer2 = UserAgentObserverSpy()
        sut = UserAgentObserverComposite(observers: [observer1, observer2])
        userAgentDummy = UserAgentSpy()
    }

    func testCallsDidFinishStartingOnAllChildren() {
        sut.userAgentDidFinishStarting(userAgentDummy)

        XCTAssertTrue(observer1.didCallUserAgentDidFinishStarting)
        XCTAssertTrue(observer2.didCallUserAgentDidFinishStarting)
        assertUserAgent()
    }

    func testCallsDidFinishStoppingOnAllChildren() {
        sut.userAgentDidFinishStopping(userAgentDummy)

        XCTAssertTrue(observer1.didCallUserAgentDidFinishStopping)
        XCTAssertTrue(observer2.didCallUserAgentDidFinishStopping)
        assertUserAgent()
    }

    func testCallsDidDetectNATOnAllChildren() {
        sut.userAgentDidDetectNAT(userAgentDummy)

        XCTAssertTrue(observer1.didCallUserAgentDidDetectNAT)
        XCTAssertTrue(observer2.didCallUserAgentDidDetectNAT)
        assertUserAgent()
    }

    private func assertUserAgent() {
        XCTAssertTrue(observer1.lastPassedUserAgent === userAgentDummy)
        XCTAssertTrue(observer2.lastPassedUserAgent === userAgentDummy)
    }
}

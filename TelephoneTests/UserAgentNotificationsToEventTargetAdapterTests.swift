//
//  UserAgentNotificationsToObservingAdapterTests.swift
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

class UserAgentNotificationsToEventTargetAdapterTests: XCTestCase {
    private var target: UserAgentEventTargetSpy!
    private var sut: UserAgentNotificationsToEventTargetAdapter!
    private var userAgent: UserAgent!
    private var center: NSNotificationCenter!

    override func setUp() {
        super.setUp()
        target = UserAgentEventTargetSpy()
        userAgent = UserAgentSpy()
        sut = UserAgentNotificationsToEventTargetAdapter(target: target, userAgent: userAgent)
        center = NSNotificationCenter.defaultCenter()
    }

    func testCallsDidFinishStarting() {
        center.postNotification(createUserAgentNotification(name: AKSIPUserAgentDidFinishStartingNotification))

        XCTAssertTrue(target.didCallUserAgentDidFinishStarting)
    }

    func testCallsDidFinishStopping() {
        center.postNotification(createUserAgentNotification(name: AKSIPUserAgentDidFinishStoppingNotification))

        XCTAssertTrue(target.didCallUserAgentDidFinishStopping)
    }

    func testCallsDidDetectNAT() {
        center.postNotification(createUserAgentNotification(name: AKSIPUserAgentDidDetectNATNotification))

        XCTAssertTrue(target.didCallUserAgentDidDetectNAT)
    }

    func testCallsDidMakeCall() {
        center.postNotification(createCallNotification(name: AKSIPCallCallingNotification))

        XCTAssertTrue(target.didCallDidMakeCall)
    }

    func testCallsUserAgentDidReceiveCall() {
        center.postNotification(createCallNotification(name: AKSIPCallIncomingNotification))

        XCTAssertTrue(target.didCallDidReceiveCall)
    }

    private func createUserAgentNotification(name name: String) -> NSNotification {
        return NSNotification(name: name, object: userAgent)
    }

    private func createCallNotification(name name: String) -> NSNotification {
        return NSNotification(name: name, object: nil)
    }
}

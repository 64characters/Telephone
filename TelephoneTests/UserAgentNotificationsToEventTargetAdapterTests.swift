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

final class UserAgentNotificationsToEventTargetAdapterTests: XCTestCase {
    private var target: UserAgentEventTargetSpy!
    private var sut: UserAgentNotificationsToEventTargetAdapter!
    private var userAgent: UserAgent!
    private var center: NotificationCenter!

    override func setUp() {
        super.setUp()
        target = UserAgentEventTargetSpy()
        userAgent = UserAgentSpy()
        sut = UserAgentNotificationsToEventTargetAdapter(target: target, agent: userAgent)
        center = NotificationCenter.default
    }

    func testCallsDidFinishStarting() {
        center.post(createUserAgentNotification(name: NSNotification.Name.AKSIPUserAgentDidFinishStarting.rawValue))

        XCTAssertTrue(target.didCallUserAgentDidFinishStarting)
    }

    func testCallsDidFinishStopping() {
        center.post(createUserAgentNotification(name: NSNotification.Name.AKSIPUserAgentDidFinishStopping.rawValue))

        XCTAssertTrue(target.didCallUserAgentDidFinishStopping)
    }

    func testCallsDidDetectNAT() {
        center.post(createUserAgentNotification(name: NSNotification.Name.AKSIPUserAgentDidDetectNAT.rawValue))

        XCTAssertTrue(target.didCallUserAgentDidDetectNAT)
    }

    func testCallsDidMakeCall() {
        center.post(createCallNotification(name: NSNotification.Name.AKSIPCallCalling.rawValue))

        XCTAssertTrue(target.didCallDidMakeCall)
    }

    func testCallsUserAgentDidReceiveCall() {
        center.post(createCallNotification(name: NSNotification.Name.AKSIPCallIncoming.rawValue))

        XCTAssertTrue(target.didCallDidReceiveCall)
    }

    fileprivate func createUserAgentNotification(name: String) -> Notification {
        return Notification(name: Notification.Name(rawValue: name), object: userAgent)
    }

    fileprivate func createCallNotification(name: String) -> Notification {
        return Notification(name: Notification.Name(rawValue: name), object: nil)
    }
}

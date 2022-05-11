//
//  UserAgentNotificationsToObservingAdapterTests.swift
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

final class AKSIPUserAgentEventSourceTests: XCTestCase {
    private var target: UserAgentEventTargetSpy!
    private var sut: AKSIPUserAgentEventSource!
    private var userAgent: UserAgent!
    private var center: NotificationCenter!

    override func setUp() {
        super.setUp()
        target = UserAgentEventTargetSpy()
        userAgent = UserAgentSpy()
        sut = AKSIPUserAgentEventSource(target: target, agent: userAgent)
        center = NotificationCenter.default
    }

    func testCallsDidFinishStarting() {
        center.post(makeUserAgentNotification(name: NSNotification.Name.AKSIPUserAgentDidFinishStarting.rawValue))

        XCTAssertTrue(target.didCallDidFinishStarting)
    }

    func testCallsDidFinishStopping() {
        center.post(makeUserAgentNotification(name: NSNotification.Name.AKSIPUserAgentDidFinishStopping.rawValue))

        XCTAssertTrue(target.didCallDidFinishStopping)
    }

    func testCallsDidDetectNAT() {
        center.post(makeUserAgentNotification(name: NSNotification.Name.AKSIPUserAgentDidDetectNAT.rawValue))

        XCTAssertTrue(target.didCallDidDetectNAT)
    }

    func testCallsDidMakeCall() {
        center.post(makeCallNotification(name: NSNotification.Name.AKSIPCallCalling.rawValue))

        XCTAssertTrue(target.didCallDidMakeCall)
    }

    func testCallsUserAgentDidReceiveCall() {
        center.post(makeCallNotification(name: NSNotification.Name.AKSIPCallIncoming.rawValue))

        XCTAssertTrue(target.didCallDidReceiveCall)
    }

    private func makeUserAgentNotification(name: String) -> Notification {
        return Notification(name: Notification.Name(rawValue: name), object: userAgent)
    }

    private func makeCallNotification(name: String) -> Notification {
        return Notification(name: Notification.Name(rawValue: name), object: nil)
    }
}

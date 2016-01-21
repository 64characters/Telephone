//
//  UserAgentNotificationsToObservingAdapterTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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

class UserAgentNotificationsToObserverAdapterTests: XCTestCase {
    private var observerSpy: UserAgentObserverSpy!
    private var sut: UserAgentNotificationsToObserverAdapter!
    private var userAgentDummy: UserAgent!
    private var notificationCenter: NSNotificationCenter!

    override func setUp() {
        super.setUp()
        observerSpy = UserAgentObserverSpy()
        userAgentDummy = UserAgentSpy()
        sut = UserAgentNotificationsToObserverAdapter(observer: observerSpy, userAgent: userAgentDummy)
        notificationCenter = NSNotificationCenter.defaultCenter()
    }

    func testCallsDidFinishStarting() {
        notificationCenter.postNotification(notificationWithName(AKSIPUserAgentDidFinishStartingNotification))

        XCTAssertTrue(observerSpy.didCallUserAgentDidFinishStarting)
    }

    func testCallsDidFinishStopping() {
        notificationCenter.postNotification(notificationWithName(AKSIPUserAgentDidFinishStoppingNotification))

        XCTAssertTrue(observerSpy.didCallUserAgentDidFinishStopping)
    }

    func testCallsDidDetectNAT() {
        notificationCenter.postNotification(notificationWithName(AKSIPUserAgentDidDetectNATNotification))

        XCTAssertTrue(observerSpy.didCallUserAgentDidDetectNAT)
    }

    private func notificationWithName(name: String) -> NSNotification {
        return NSNotification(name: name, object: userAgentDummy)
    }
}

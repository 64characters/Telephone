//
//  AKSIPCallEventSourceTests.swift
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

class AKSIPCallEventSourceTests: XCTestCase {
    func testCallsDidMake() {
        let center = NotificationCenter.default
        let target = CallEventTargetSpy()
        let call = CallTestFactory().make()
        withExtendedLifetime(AKSIPCallEventSource(center: center, target: target)) {

            center.post(Notification(name: .AKSIPCallCalling, object: call, userInfo: nil))

            XCTAssertTrue(target.didCallDidMake)
            XCTAssertTrue(target.invokedCall === call)
        }
    }

    func testCallsDidReceive() {
        let center = NotificationCenter.default
        let target = CallEventTargetSpy()
        let call = CallTestFactory().make()
        withExtendedLifetime(AKSIPCallEventSource(center: center, target: target)) {

            center.post(Notification(name: .AKSIPCallIncoming, object: call, userInfo: nil))

            XCTAssertTrue(target.didCallDidReceive)
            XCTAssertTrue(target.invokedCall === call)
        }
    }

    func testCallsIsConnecting() {
        let center = NotificationCenter.default
        let target = CallEventTargetSpy()
        let call = CallTestFactory().make()
        withExtendedLifetime(AKSIPCallEventSource(center: center, target: target)) {

            center.post(Notification(name: .AKSIPCallConnecting, object: call, userInfo: nil))

            XCTAssertTrue(target.didCallIsConnecting)
            XCTAssertTrue(target.invokedCall === call)
        }
    }

    func testCallsDidDisconnect() {
        let center = NotificationCenter.default
        let target = CallEventTargetSpy()
        let call = CallTestFactory().make()
        withExtendedLifetime(AKSIPCallEventSource(center: center, target: target)) {

            center.post(Notification(name: .AKSIPCallDidDisconnect, object: call, userInfo: nil))

            XCTAssertTrue(target.didCallDidDisconnect)
            XCTAssertTrue(target.invokedCall === call)
        }
    }
}

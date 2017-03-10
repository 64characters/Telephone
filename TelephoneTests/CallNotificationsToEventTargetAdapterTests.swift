//
//  CallNotificationsToEventTargetAdapterTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

class CallNotificationsToEventTargetAdapterTests: XCTestCase {
    func testCallsDidDisconnect() {
        let center = NotificationCenter.default
        let target = CallEventTargetSpy()
        let call = SimpleCall(
            account: SimpleAccount(uuid: "any-uuid", domain: "any-domain"),
            remote: URI(user: "any-user", host: "any-host"),
            date: Date(),
            duration: 0,
            isIncoming: false,
            isMissed: false
        )
        withExtendedLifetime(CallNotificationsToEventTargetAdapter(center: center, target: target)) {

            center.post(Notification(name: Notification.Name.AKSIPCallDidDisconnect, object: call, userInfo: nil))

            XCTAssertTrue(target.didCallDidDisconnect)
        }
    }
}

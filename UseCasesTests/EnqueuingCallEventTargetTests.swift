//
//  EnqueuingCallEventTargetTests.swift
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

import XCTest
import UseCases
import UseCasesTestDoubles

final class EnqueuingCallEventTargetTests: XCTestCase {
    func testAddsBlockToQueueOnDidMake() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingCallEventTarget(origin: CallEventTargetSpy(), queue: queue)

        sut.didMake(CallTestFactory().make())

        XCTAssertTrue(queue.didCallAdd)
    }

    func testAddsBockToQueueOnDidReceive() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingCallEventTarget(origin: CallEventTargetSpy(), queue: queue)

        sut.didReceive(CallTestFactory().make())

        XCTAssertTrue(queue.didCallAdd)
    }

    func testAddsBlockToQueueOnIsConnecting() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingCallEventTarget(origin: CallEventTargetSpy(), queue: queue)

        sut.isConnecting(CallTestFactory().make())

        XCTAssertTrue(queue.didCallAdd)
    }

    func testAddsBockToQueueOnDidDisconnect() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingCallEventTarget(origin: CallEventTargetSpy(), queue: queue)

        sut.didDisconnect(CallTestFactory().make())

        XCTAssertTrue(queue.didCallAdd)
    }

    func testCallsDidMakeOnOriginWithTheSameArgumentOnDidMake() {
        let origin = CallEventTargetSpy()
        let sut = EnqueuingCallEventTarget(origin: origin, queue: SyncExecutionQueue())
        let call = CallTestFactory().make()

        sut.didMake(call)

        XCTAssertTrue(origin.didCallDidMake)
        XCTAssertTrue(origin.invokedCall === call)
    }

    func testCallsDidMakeOnOriginWithTheSameArgumentOnDidReceive() {
        let origin = CallEventTargetSpy()
        let sut = EnqueuingCallEventTarget(origin: origin, queue: SyncExecutionQueue())
        let call = CallTestFactory().make()

        sut.didReceive(call)

        XCTAssertTrue(origin.didCallDidReceive)
        XCTAssertTrue(origin.invokedCall === call)
    }

    func testCallsIsConnectingOnOriginWithTheSameArgumentOnIsConnecting() {
        let origin = CallEventTargetSpy()
        let sut = EnqueuingCallEventTarget(origin: origin, queue: SyncExecutionQueue())
        let call = CallTestFactory().make()

        sut.isConnecting(call)

        XCTAssertTrue(origin.didCallIsConnecting)
        XCTAssertTrue(origin.invokedCall === call)
    }

    func testCallsDidDisconnectOnOriginWithTheSameArgumentOnDidDisconnect() {
        let origin = CallEventTargetSpy()
        let sut = EnqueuingCallEventTarget(origin: origin, queue: SyncExecutionQueue())
        let call = CallTestFactory().make()

        sut.didDisconnect(call)

        XCTAssertTrue(origin.didCallDidDisconnect)
        XCTAssertTrue(origin.invokedCall === call)
    }
}

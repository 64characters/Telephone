//
//  CallsUserAttentionRequestTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

final class CallsUserAttentionRequestTests: XCTestCase {
    func testCallsStartOnOriginOnStart() {
        let origin = UserAttentionRequestSpy()
        let sut = CallsUserAttentionRequest(origin: origin, calls: CallsStub())

        sut.start()

        XCTAssertTrue(origin.didStart)
    }

    func testCallsStopOnOriginOnStopWhenThereAreNoIncomingCalls() {
        let origin = UserAttentionRequestSpy()
        let sut = CallsUserAttentionRequest(origin: origin, calls: CallsStub(haveIncoming: false))

        sut.stop()

        XCTAssertTrue(origin.didStop)
    }

    func testDoesNotCallStopOnOriginOnStopWhenThereAreIncomingCalls() {
        let origin = UserAttentionRequestSpy()
        let sut = CallsUserAttentionRequest(origin: origin, calls: CallsStub(haveIncoming: true))

        sut.stop()

        XCTAssertFalse(origin.didStop)
    }
}

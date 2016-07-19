//
//  DelayingUserAgentSoundIOSelectionUseCaseTests.swift
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

final class DelayingUserAgentSoundIOSelectionUseCaseTests: XCTestCase {
    private var userAgent: UserAgentSpy!
    private var sut: DelayingUserAgentSoundIOSelectionUseCase!

    override func setUp() {
        super.setUp()
        userAgent = UserAgentSpy()
        sut = DelayingUserAgentSoundIOSelectionUseCase(
            useCase: UserAgentSoundIOSelectionUseCaseFake(userAgent: userAgent),
            userAgent: userAgent
        )
    }

    func testDoesNotSelectIOOnUserAgentDidFinishStarting() {
        sut.userAgentDidFinishStarting(userAgent)

        XCTAssertFalse(userAgent.didSelectSoundIO)
    }

    func testSelectsIOOnUserAgentDidMakeCall() {
        sut.userAgentDidFinishStarting(userAgent)

        sut.userAgentDidMakeCall(userAgent)

        XCTAssertTrue(userAgent.didSelectSoundIO)
    }

    func testSelectsIOOnUserAgentDidReceiveCall() {
        sut.userAgentDidFinishStarting(userAgent)

        sut.userAgentDidReceiveCall(userAgent)

        XCTAssertTrue(userAgent.didSelectSoundIO)
    }

    func testSelectsIOOnceWhenUserAgentMakesOrReceivesCallMoreThanOnce() {
        sut.userAgentDidFinishStarting(userAgent)

        sut.userAgentDidMakeCall(userAgent)
        sut.userAgentDidReceiveCall(userAgent)
        sut.userAgentDidMakeCall(userAgent)
        sut.userAgentDidReceiveCall(userAgent)

        XCTAssertEqual(userAgent.soundIOSelectionCallCount, 1)
    }

    func testSelectsIOOnUserAgentDidMakeCallAfterRestart() {
        sut.userAgentDidFinishStarting(userAgent)
        sut.userAgentDidMakeCall(userAgent)

        sut.userAgentDidFinishStopping(userAgent)
        sut.userAgentDidFinishStarting(userAgent)
        sut.userAgentDidMakeCall(userAgent)

        XCTAssertEqual(userAgent.soundIOSelectionCallCount, 2)
    }

    func testDoesNotSelectIOIfUserAgentWasNotStarted() {
        sut.userAgentDidMakeCall(userAgent)
        sut.userAgentDidReceiveCall(userAgent)

        XCTAssertFalse(userAgent.didSelectSoundIO)
    }

    func testDoesNotSelectIOIfUserAgentWasStopped() {
        sut.userAgentDidFinishStarting(userAgent)

        sut.userAgentDidFinishStopping(userAgent)
        sut.userAgentDidMakeCall(userAgent)
        sut.userAgentDidReceiveCall(userAgent)

        XCTAssertFalse(userAgent.didSelectSoundIO)
    }

    func testSelectsIOOnUserAgentDidMakeCallAfterExecuteIsCalled() {
        sut.userAgentDidFinishStarting(userAgent)
        sut.userAgentDidMakeCall(userAgent)

        sut.execute()
        sut.userAgentDidMakeCall(userAgent)

        XCTAssertEqual(userAgent.soundIOSelectionCallCount, 2)
    }

    func testSelectsIOOnUserAgentDidMakeCallAfterSystemAudioDevicesUpdate() {
        sut.userAgentDidFinishStarting(userAgent)
        sut.userAgentDidMakeCall(userAgent)

        sut.systemAudioDevicesDidUpdate()
        sut.userAgentDidMakeCall(userAgent)

        XCTAssertEqual(userAgent.soundIOSelectionCallCount, 2)
    }

    func testSelectsIOOnUserAgentDidReceiveCallAfterSystemAudioDevicesUpdate() {
        sut.userAgentDidFinishStarting(userAgent)
        sut.userAgentDidMakeCall(userAgent)

        sut.systemAudioDevicesDidUpdate()
        sut.userAgentDidReceiveCall(userAgent)

        XCTAssertEqual(userAgent.soundIOSelectionCallCount, 2)
    }

    func testSelectsIOOnExecuteWhenUserAgentHasActiveCalls() {
        sut.userAgentDidFinishStarting(userAgent)
        sut.userAgentDidMakeCall(userAgent)
        userAgent.simulateActiveCalls()

        sut.systemAudioDevicesDidUpdate()

        XCTAssertEqual(userAgent.soundIOSelectionCallCount, 2)
    }
}

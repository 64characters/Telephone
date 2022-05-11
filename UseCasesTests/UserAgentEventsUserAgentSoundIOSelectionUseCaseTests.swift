//
//  UserAgentEventsUserAgentSoundIOSelectionUseCaseTests.swift
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

final class UserAgentEventsUserAgentSoundIOSelectionUseCaseTests: XCTestCase {
    private var agent: UserAgentSpy!
    private var sut: UserAgentEventsUserAgentSoundIOSelectionUseCase!

    override func setUp() {
        super.setUp()
        agent = UserAgentSpy()
        sut = UserAgentEventsUserAgentSoundIOSelectionUseCase(
            useCase: UserAgentSoundIOSelectionUseCaseFake(agent: agent),
            agent: agent,
            calls: CallsStub(haveActive: false)
        )
    }

    func testDoesNotSelectIOOnDidFinishStarting() {
        sut.didFinishStarting(agent)

        XCTAssertFalse(agent.didSelectSoundIO)
    }

    func testSelectsIOOnDidMakeCall() {
        sut.didFinishStarting(agent)

        sut.didMakeCall(agent)

        XCTAssertTrue(agent.didSelectSoundIO)
    }

    func testSelectsIOOnDidReceiveCall() {
        sut.didFinishStarting(agent)

        sut.didReceiveCall(agent)

        XCTAssertTrue(agent.didSelectSoundIO)
    }

    func testSelectsIOOnceWhenUserAgentMakesOrReceivesCallMoreThanOnce() {
        sut.didFinishStarting(agent)

        sut.didMakeCall(agent)
        sut.didReceiveCall(agent)
        sut.didMakeCall(agent)
        sut.didReceiveCall(agent)

        XCTAssertEqual(agent.soundIOSelectionCallCount, 1)
    }

    func testSelectsIOOnDidMakeCallAfterRestart() {
        sut.didFinishStarting(agent)
        sut.didMakeCall(agent)

        sut.didFinishStopping(agent)
        sut.didFinishStarting(agent)
        sut.didMakeCall(agent)

        XCTAssertEqual(agent.soundIOSelectionCallCount, 2)
    }

    func testDoesNotSelectIOIfUserAgentWasNotStarted() {
        sut.didMakeCall(agent)
        sut.didReceiveCall(agent)

        XCTAssertFalse(agent.didSelectSoundIO)
    }

    func testDoesNotSelectIOIfUserAgentWasStopped() {
        sut.didFinishStarting(agent)

        sut.didFinishStopping(agent)
        sut.didMakeCall(agent)
        sut.didReceiveCall(agent)

        XCTAssertFalse(agent.didSelectSoundIO)
    }

    func testSelectsIOOnDidMakeCallAfterExecuteIsCalled() {
        sut.didFinishStarting(agent)
        sut.didMakeCall(agent)

        sut.execute()
        sut.didMakeCall(agent)

        XCTAssertEqual(agent.soundIOSelectionCallCount, 2)
    }

    func testSelectsIOOnDidReceiveCallAfterExecuteIsCalled() {
        sut.didFinishStarting(agent)
        sut.didMakeCall(agent)

        sut.execute()
        sut.didReceiveCall(agent)

        XCTAssertEqual(agent.soundIOSelectionCallCount, 2)
    }

    func testSelectsIOOnExecuteWhenThereAreActiveCalls() {
        let agent = UserAgentSpy()
        let sut = UserAgentEventsUserAgentSoundIOSelectionUseCase(
            useCase: UserAgentSoundIOSelectionUseCaseFake(agent: agent),
            agent: agent,
            calls: CallsStub(haveActive: true)
        )
        sut.didFinishStarting(agent)
        sut.didMakeCall(agent)

        sut.execute()

        XCTAssertEqual(agent.soundIOSelectionCallCount, 2)
    }
}

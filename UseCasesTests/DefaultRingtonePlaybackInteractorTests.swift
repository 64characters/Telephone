//
//  DefaultRingtonePlaybackInteractorTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
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

class DefaultRingtonePlaybackInteractorTests: XCTestCase {
    private(set) var ringtoneSpy: RingtoneSpy!
    private(set) var ringtoneFactorySpy: RingtoneFactorySpy!
    private(set) var sut: RingtonePlaybackInteractor!

    override func setUp() {
        super.setUp()
        ringtoneSpy = RingtoneSpy()
        ringtoneFactorySpy = RingtoneFactorySpy()
        ringtoneFactorySpy.stubWith(ringtoneSpy)
        sut = DefaultRingtonePlaybackInteractor(factory: ringtoneFactorySpy)
    }

    func testStartsPlayingRingtone() {
        try! sut.start()

        XCTAssertTrue(ringtoneSpy.didCallStartPlaying)
    }

    func testStopsPlayingRingtone() {
        try! sut.start()
        sut.stop()

        XCTAssertTrue(ringtoneSpy.didCallStopPlaying)
    }

    func testPlayingFlagIsTrueOnStartPlaying() {
        try! sut.start()

        XCTAssertTrue(sut.playing)
    }

    func testPlayingFlagIsFalseOnStopPlaying() {
        try! sut.start()
        sut.stop()

        XCTAssertFalse(sut.playing)
    }

    func testInterval() {
        try! sut.start()

        XCTAssertEqual(ringtoneFactorySpy.invokedInterval, DefaultRingtonePlaybackInteractor.interval)
    }

    func testDoesNotCreateRingtoneIfAlreadyExists() {
        try! sut.start()
        try! sut.start()

        XCTAssertEqual(ringtoneFactorySpy.createRingtoneCallCount, 1)
    }

    func testStopsPlayingRingtoneOnceOnTwoConsecutiveCallsTostop() {
        try! sut.start()
        sut.stop()
        sut.stop()

        XCTAssertEqual(ringtoneSpy.stopPlayingCallCount, 1)
    }
}

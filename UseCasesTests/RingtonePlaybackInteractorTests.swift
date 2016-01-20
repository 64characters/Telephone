//
//  RingtonePlaybackInteractorTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexei Kuznetsov
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

class RingtonePlaybackInteractorTests: XCTestCase {
    private(set) var ringtoneSpy: RingtoneSpy!
    private(set) var ringtoneFactorySpy: RingtoneFactorySpy!
    private(set) var sut: RingtonePlaybackInteractorInput!

    override func setUp() {
        super.setUp()
        ringtoneSpy = RingtoneSpy()
        ringtoneFactorySpy = RingtoneFactorySpy()
        ringtoneFactorySpy.stubWith(ringtoneSpy)
        sut = RingtonePlaybackInteractor(ringtoneFactory: ringtoneFactorySpy)
    }

    func testStartsPlayingRingtone() {
        try! sut.startPlayingRingtone()

        XCTAssertTrue(ringtoneSpy.didCallStartPlaying)
    }

    func testStopsPlayingRingtone() {
        try! sut.startPlayingRingtone()
        sut.stopPlayingRingtone()

        XCTAssertTrue(ringtoneSpy.didCallStopPlaying)
    }

    func testTimerInterval() {
        try! sut.startPlayingRingtone()

        XCTAssertEqual(ringtoneFactorySpy.invokedTimeInterval, RingtonePlaybackInteractor.ringtoneInterval)
    }

    func testDoesNotCreateRingtoneIfAlreadyExists() {
        try! sut.startPlayingRingtone()
        try! sut.startPlayingRingtone()

        XCTAssertEqual(ringtoneFactorySpy.createRingtoneCallCount, 1)
    }

    func testStopsPlayingRingtoneOnceOnTwoConsecutiveCallsToStopPlayingRingtone() {
        try! sut.startPlayingRingtone()
        sut.stopPlayingRingtone()
        sut.stopPlayingRingtone()

        XCTAssertEqual(ringtoneSpy.stopPlayingCallCount, 1)
    }
}

//
//  RepeatingSoundTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexei Kuznetsov. All rights reserved.
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

@testable import UseCases
import UseCasesTestDoubles
import XCTest

class RepeatingSoundTests: XCTestCase {
    private(set) var soundSpy: SoundSpy!
    private(set) var timerFactorySpy: TimerFactorySpy!
    private(set) var timerSpy: TimerSpy!
    private(set) var sut: RepeatingSound!

    override func setUp() {
        super.setUp()
        soundSpy = SoundSpy()
        timerFactorySpy = TimerFactorySpy()
        timerSpy = TimerSpy()
        timerFactorySpy.stubWith(timerSpy)
        sut = RepeatingSound(sound: soundSpy, timeInterval: 1, timerFactory: timerFactorySpy)
    }

    func testCreatesRepeatingTimerOnStartPlaying() {
        sut.startPlaying()

        XCTAssertTrue(timerFactorySpy.didCallCreateRepeatingTimer)
        XCTAssertEqual(timerFactorySpy.invokedTimeInterval, 1)
    }

    func testInvalidatesRepeatingTimerOnStopPlaying() {
        sut.startPlaying()
        sut.stopPlaying()

        XCTAssertTrue(timerSpy.didCallInvalidate)
    }

    func testCreatesTimerOnceOnTwoConsecutiveCallsToStartPlaying() {
        sut.startPlaying()
        sut.startPlaying()

        XCTAssertEqual(timerFactorySpy.createRepeatingTimerCallCount, 1)
    }

    func testInvalidatesTimerOnceOnTwoConsecutiveCallsToStopPlaying() {
        sut.startPlaying()
        sut.stopPlaying()
        sut.stopPlaying()

        XCTAssertEqual(timerSpy.invalidateCallCount, 1)
    }

    func testPlaysSoundOnStartPlaying() {
        sut.startPlaying()

        XCTAssertTrue(soundSpy.didCallPlay)
    }

    func testStopsSoundOnStopPlaying() {
        sut.startPlaying()
        sut.stopPlaying()

        XCTAssertTrue(soundSpy.didCallStop)
    }
}

//
//  RepeatingSoundTests.swift
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

@testable import UseCases
import UseCasesTestDoubles
import XCTest

class RepeatingSoundTests: XCTestCase {
    private(set) var sound: SoundSpy!
    private(set) var factory: TimerFactorySpy!
    private(set) var timer: TimerSpy!
    private(set) var sut: RepeatingSound!

    override func setUp() {
        super.setUp()
        sound = SoundSpy(eventTarget: NullSoundEventTarget())
        factory = TimerFactorySpy()
        timer = TimerSpy()
        factory.stubWith(timer)
        sut = RepeatingSound(sound: sound, interval: 1, factory: factory)
    }

    func testCreatesRepeatingTimerOnStartPlaying() {
        sut.startPlaying()

        XCTAssertTrue(factory.didCallCreateRepeatingTimer)
        XCTAssertEqual(factory.invokedInterval, 1)
    }

    func testInvalidatesRepeatingTimerOnStopPlaying() {
        sut.startPlaying()
        sut.stopPlaying()

        XCTAssertTrue(timer.didCallInvalidate)
    }

    func testCreatesTimerOnceOnTwoConsecutiveCallsToStartPlaying() {
        sut.startPlaying()
        sut.startPlaying()

        XCTAssertEqual(factory.createRepeatingTimerCallCount, 1)
    }

    func testInvalidatesTimerOnceOnTwoConsecutiveCallsToStopPlaying() {
        sut.startPlaying()
        sut.stopPlaying()
        sut.stopPlaying()

        XCTAssertEqual(timer.invalidateCallCount, 1)
    }

    func testPlaysSoundOnStartPlaying() {
        sut.startPlaying()

        XCTAssertTrue(sound.didCallPlay)
    }

    func testStopsSoundOnStopPlaying() {
        sut.startPlaying()
        sut.stopPlaying()

        XCTAssertTrue(sound.didCallStop)
    }
}

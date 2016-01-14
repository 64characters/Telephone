//
//  RepeatingSoundTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

    func testCreatesTimerOnceOnTwoSuccessiveCallsToStartPlaying() {
        sut.startPlaying()
        sut.startPlaying()

        XCTAssertEqual(timerFactorySpy.createRepeatingTimerCallCount, 1)
    }

    func testInvalidatesTimerOnceOnTwoSuccessiveCallsToStopPlaying() {
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

//
//  ConditionalRingtonePlaybackInteractorTests.swift
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

class ConditionalRingtonePlaybackInteractorTests: XCTestCase {
    private var origin: RingtonePlaybackInteractorSpy!
    private var delegate: ConditionalRingtonePlaybackInteractorTestDelegate!
    private var sut: ConditionalRingtonePlaybackInteractor!

    override func setUp() {
        super.setUp()
        origin = RingtonePlaybackInteractorSpy()
        delegate = ConditionalRingtonePlaybackInteractorTestDelegate()
        sut = ConditionalRingtonePlaybackInteractor(origin: origin, delegate: delegate)
    }

    func testCallsStartOnOrigin() {
        try! sut.start()

        XCTAssertTrue(origin.didCallStart)
    }

    func testCallsStopOnOrigin() {
        sut.stop()

        XCTAssertTrue(origin.didCallStop)
    }

    func testDoesNotCallStopOnOriginWhenDelegateReturnsFalse() {
        delegate.forbidStoppingPlayback()

        sut.stop()

        XCTAssertFalse(origin.didCallStop)
    }

    func testReturnsPlayingFlagFromOrigin() {
        try! origin.start()

        XCTAssertTrue(sut.playing)
    }
}

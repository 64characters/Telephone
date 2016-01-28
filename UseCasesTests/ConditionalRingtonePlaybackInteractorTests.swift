//
//  ConditionalRingtonePlaybackInteractorTests.swift
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

class ConditionalRingtonePlaybackInteractorTests: XCTestCase {
    private var originSpy: RingtonePlaybackInteractorSpy!
    private var delegate: ConditionalRingtonePlaybackInteractorTestDelegate!
    private var sut: ConditionalRingtonePlaybackInteractor!

    override func setUp() {
        super.setUp()
        originSpy = RingtonePlaybackInteractorSpy()
        delegate = ConditionalRingtonePlaybackInteractorTestDelegate()
        sut = ConditionalRingtonePlaybackInteractor(origin: originSpy, delegate: delegate)
    }

    func testCallsStartPlayingRingtoneOnOrigin() {
        try! sut.startPlayingRingtone()

        XCTAssertTrue(originSpy.didCallStartPlayingRingtone)
    }

    func testCallsStopPlayingRingtoneOnOrigin() {
        sut.stopPlayingRingtone()

        XCTAssertTrue(originSpy.didCallStopPlayingRingtone)
    }

    func testDoesNotCallStopPlayingRingtoneOnOriginWhenDelegateReturnsFalse() {
        delegate.forbidStoppingRingtone()

        sut.stopPlayingRingtone()

        XCTAssertFalse(originSpy.didCallStopPlayingRingtone)
    }
}

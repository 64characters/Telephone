//
//  ConditionalRingtonePlaybackUseCaseTests.swift
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

final class ConditionalRingtonePlaybackUseCaseTests: XCTestCase {
    private var origin: RingtonePlaybackUseCaseSpy!
    private var delegate: ConditionalRingtonePlaybackUseCaseTestDelegate!
    private var sut: ConditionalRingtonePlaybackUseCase!

    override func setUp() {
        super.setUp()
        origin = RingtonePlaybackUseCaseSpy()
        delegate = ConditionalRingtonePlaybackUseCaseTestDelegate()
        sut = ConditionalRingtonePlaybackUseCase(origin: origin, delegate: delegate)
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

        XCTAssertTrue(sut.isPlaying)
    }
}

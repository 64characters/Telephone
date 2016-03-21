//
//  RingtoneOutputUpdateInteractorTests.swift
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

class RingtoneOutputUpdateInteractorTests: XCTestCase {
    private var playback: RingtonePlaybackInteractorSpy!
    private var sut: ThrowingInteractor!

    override func setUp() {
        super.setUp()
        playback = RingtonePlaybackInteractorSpy()
        sut = RingtoneOutputUpdateInteractor(playback: playback)
    }

    func testRestartsPlaybackWhenPlaying() {
        try! playback.start()

        try! sut.execute()

        XCTAssertTrue(playback.didCallStop)
        XCTAssertTrue(playback.didCallStart)
    }

    func testDoesNotRestartPlaybackWhenNotPlaying() {
        try! sut.execute()

        XCTAssertFalse(playback.didCallStop)
        XCTAssertFalse(playback.didCallStart)
    }
}

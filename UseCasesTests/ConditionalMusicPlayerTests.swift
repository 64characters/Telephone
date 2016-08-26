//
//  ConditionalMusicPlayerTests.swift
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

final class ConditionalMusicPlayerTests: XCTestCase {
    func testPausesAndResumesWhenEnabledInUserDefaults() {
        let origin = MusicPlayerSpy()
        let defaults = MusicPlayerUserDefaultsFake()
        defaults.shouldPause = true
        let sut = ConditionalMusicPlayer(origin: origin, defaults: defaults)

        sut.pause()
        sut.resume()

        XCTAssertTrue(origin.didCallPause)
        XCTAssertTrue(origin.didCallResume)
    }

    func testDoesNotPauseAndResumeWhenDisabledInUserDefaults() {
        let origin = MusicPlayerSpy()
        let defaults = MusicPlayerUserDefaultsFake()
        defaults.shouldPause = false
        let sut = ConditionalMusicPlayer(origin: origin, defaults: defaults)

        sut.pause()
        sut.resume()

        XCTAssertFalse(origin.didCallPause)
        XCTAssertFalse(origin.didCallResume)
    }
}

//
//  CallsMusicPlayerTests.swift
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

final class CallsMusicPlayerTests: XCTestCase {
    func testResumesWhenThereAreNoActiveCalls() {
        let origin = MusicPlayerSpy()
        let sut = CallsMusicPlayer(origin: origin, calls: CallsStub(haveActive: false))

        sut.resume()

        XCTAssertTrue(origin.didCallResume)
    }

    func testDoesNotResumeWhenThereAreActiveCalls() {
        let origin = MusicPlayerSpy()
        let sut = CallsMusicPlayer(origin: origin, calls: CallsStub(haveActive: true))

        sut.resume()

        XCTAssertFalse(origin.didCallResume)
    }

    func testPausesWhenThereAreNoActiveCalls() {
        let origin = MusicPlayerSpy()
        let sut = CallsMusicPlayer(origin: origin, calls: CallsStub(haveActive: false))

        sut.pause()

        XCTAssertTrue(origin.didCallPause)
    }

    func testPausesWhenThereAreActiveCalls() {
        let origin = MusicPlayerSpy()
        let sut = CallsMusicPlayer(origin: origin, calls: CallsStub(haveActive: true))

        sut.pause()

        XCTAssertTrue(origin.didCallPause)
    }
}

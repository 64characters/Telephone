//
//  SoundPlaybackInteractorTests.swift
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

class SoundPlaybackInteractorTests: XCTestCase {
    private var soundFactorySpy: SoundFactorySpy!
    private var sut: SoundPlaybackInteractor!

    override func setUp() {
        super.setUp()
        soundFactorySpy = SoundFactorySpy()
        sut = SoundPlaybackInteractor(soundFactory: soundFactorySpy)
    }

    func testCreatesSoundOnPlay() {
        try! sut.play()

        XCTAssertTrue(soundFactorySpy.didCallCreateSound)
    }

    func testPlaysSoundOnPlay() {
        try! sut.play()

        XCTAssertTrue(soundFactorySpy.lastCreatedSound.didCallPlay)
    }

    func testStopsFirstSondOnSecondPlay() {
        try! sut.play()
        let soundSpy = soundFactorySpy.lastCreatedSound
        try! sut.play()

        XCTAssertTrue(soundSpy.didCallStop)
    }

    func testKeepsReferenceToSoundDuringPlayback() {
        try! sut.play()

        XCTAssertTrue(sut.sound === soundFactorySpy.lastCreatedSound)
    }

    func testDoesNotKeepReferenceToSoundAfterSoundStoppedPlaying() {
        try! sut.play()

        soundFactorySpy.lastCreatedSound.notifyObserverOfPlaybackCompletion()

        XCTAssertNil(sut.sound)
    }
}

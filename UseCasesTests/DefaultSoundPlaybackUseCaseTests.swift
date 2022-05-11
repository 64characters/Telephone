//
//  DefaultSoundPlaybackUseCaseTests.swift
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

final class DefaultSoundPlaybackUseCaseTests: XCTestCase {
    private var factory: SoundFactorySpy!
    private var sut: DefaultSoundPlaybackUseCase!

    override func setUp() {
        super.setUp()
        factory = SoundFactorySpy()
        sut = DefaultSoundPlaybackUseCase(factory: factory)
    }

    func testCreatesSoundOnPlay() {
        try! sut.play()

        XCTAssertTrue(factory.didCallCreateSound)
    }

    func testPlaysSoundOnPlay() {
        try! sut.play()

        XCTAssertTrue(factory.lastCreatedSound!.didCallPlay)
    }

    func testStopsSoundOnStop() {
        try! sut.play()

        sut.stop()

        XCTAssertTrue(factory.lastCreatedSound!.didCallStop)
    }

    func testStopsFirstSondOnSecondPlay() {
        try! sut.play()
        let sound = factory.lastCreatedSound
        try! sut.play()

        XCTAssertTrue(sound!.didCallStop)
    }

    func testKeepsReferenceToSoundDuringPlayback() {
        try! sut.play()

        XCTAssertTrue(sut.sound === factory.lastCreatedSound)
    }

    func testDoesNotKeepReferenceToSoundAfterSoundStoppedPlaying() {
        try! sut.play()

        factory.lastCreatedSound!.notifyObserverOfPlaybackCompletion()

        XCTAssertNil(sut.sound)
    }
}

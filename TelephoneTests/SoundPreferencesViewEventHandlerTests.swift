//
//  SoundPreferencesViewEventHandlerTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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

import UseCasesTestDoubles
import XCTest

class SoundPreferencesViewEventHandlerTests: XCTestCase {
    private var interactorFactorySpy: InteractorFactorySpy!
    private var ringtoneOutputUpdateInteractorSpy: ThrowingInteractorSpy!
    private var ringtoneSoundPlaybackInteractorSpy: SoundPlaybackInteractorSpy!
    private var sut: SoundPreferencesViewEventHandler!

    override func setUp() {
        super.setUp()
        interactorFactorySpy = InteractorFactorySpy()
        ringtoneOutputUpdateInteractorSpy = ThrowingInteractorSpy()
        ringtoneSoundPlaybackInteractorSpy = SoundPlaybackInteractorSpy()
        sut = SoundPreferencesViewEventHandler(
            interactorFactory: interactorFactorySpy,
            presenterFactory: PresenterFactoryImpl(),
            ringtoneOutputUpdateInteractor: ringtoneOutputUpdateInteractorSpy,
            ringtoneSoundPlaybackInteractor: ringtoneSoundPlaybackInteractorSpy,
            userAgent: UserAgentSpy()
        )
    }

    func testExecutesUserDefaultsSoundIOLoadInteractorOnViewDataReload() {
        let interactorSpy = ThrowingInteractorSpy()
        interactorFactorySpy.stubWithUserDefaultsSoundIOLoadInteractor(interactorSpy)

        sut.viewShouldReloadData(SoundPreferencesViewSpy())

        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesUserDefaultsSoundIOSaveInteractorWithExpectedArgumentsOnSoundIOChange() {
        let interactorSpy = InteractorSpy()
        interactorFactorySpy.stubWithUserDefaultsSoundIOSaveInteractor(interactorSpy)
        interactorFactorySpy.stubWithUserAgentSoundIOSelectionInteractor(ThrowingInteractorSpy())
        let soundIO = SoundIO(soundInput: "input", soundOutput: "output1", ringtoneOutput: "output2")

        sut.viewDidChangeSoundInput(
            soundIO.soundInput, soundOutput: soundIO.soundOutput, ringtoneOutput: soundIO.ringtoneOutput
        )

        XCTAssertEqual(interactorFactorySpy.invokedSoundIO, soundIO)
        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesUserAgentSoundIOSelectionInteractorOnSoundIOChange() {
        let interactorSpy = ThrowingInteractorSpy()
        interactorFactorySpy.stubWithUserAgentSoundIOSelectionInteractor(interactorSpy)
        interactorFactorySpy.stubWithUserDefaultsSoundIOSaveInteractor(InteractorSpy())

        sut.viewDidChangeSoundInput("any-input", soundOutput: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesRingtoneOutputUpdateInteractorOnSoundIOChange() {
        interactorFactorySpy.stubWithUserAgentSoundIOSelectionInteractor(ThrowingInteractorSpy())
        interactorFactorySpy.stubWithUserDefaultsSoundIOSaveInteractor(InteractorSpy())

        sut.viewDidChangeSoundInput("any-input", soundOutput: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(ringtoneOutputUpdateInteractorSpy.didCallExecute)
    }

    func testExecutesUserDefaultsRingtoneSoundNameSaveInteractorWithExpectedArgumentsOnRingtoneNameChange() {
        let interactorSpy = InteractorSpy()
        interactorFactorySpy.stubWithUserDefaultsRingtoneSoundNameSaveInteractor(interactorSpy)

        sut.viewDidChangeRingtoneName("sound-name")

        XCTAssertEqual(interactorFactorySpy.invokedRingtoneSoundName, "sound-name")
        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testPlaysRingtoneSoundOnRingtoneNameChange() {
        interactorFactorySpy.stubWithUserDefaultsRingtoneSoundNameSaveInteractor(InteractorSpy())

        sut.viewDidChangeRingtoneName("any-name")

        XCTAssertTrue(ringtoneSoundPlaybackInteractorSpy.didCallPlay)
    }
}

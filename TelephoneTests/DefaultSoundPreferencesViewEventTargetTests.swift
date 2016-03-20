//
//  DefaultSoundPreferencesViewEventTargetTests.swift
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

class DefaultSoundPreferencesViewEventTargetTests: XCTestCase {
    private var factorySpy: InteractorFactorySpy!
    private var ringtoneOutputUpdateSpy: ThrowingInteractorSpy!
    private var soundPlaybackSpy: SoundPlaybackInteractorSpy!
    private var sut: DefaultSoundPreferencesViewEventTarget!

    override func setUp() {
        super.setUp()
        factorySpy = InteractorFactorySpy()
        ringtoneOutputUpdateSpy = ThrowingInteractorSpy()
        soundPlaybackSpy = SoundPlaybackInteractorSpy()
        sut = DefaultSoundPreferencesViewEventTarget(
            interactorFactory: factorySpy,
            presenterFactory: PresenterFactory(),
            ringtoneOutputUpdate: ringtoneOutputUpdateSpy,
            ringtoneSoundPlayback: soundPlaybackSpy,
            userAgent: UserAgentSpy()
        )
    }

    func testExecutesUserDefaultsSoundIOLoadInteractorOnViewDataReload() {
        let interactorSpy = ThrowingInteractorSpy()
        factorySpy.stubWithUserDefaultsSoundIOLoadInteractor(interactorSpy)

        sut.viewShouldReloadData(SoundPreferencesViewSpy())

        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesUserDefaultsSoundIOLoadInteractorOnSoundIOReload() {
        let spy = ThrowingInteractorSpy()
        factorySpy.stubWithUserDefaultsSoundIOLoadInteractor(spy)

        sut.viewShouldReloadSoundIO(SoundPreferencesViewSpy())

        XCTAssertTrue(spy.didCallExecute)
    }

    func testExecutesUserDefaultsSoundIOSaveInteractorWithExpectedArgumentsOnSoundIOChange() {
        let interactorSpy = InteractorSpy()
        factorySpy.stubWithUserDefaultsSoundIOSaveInteractor(interactorSpy)
        factorySpy.stubWithUserAgentSoundIOSelectionInteractor(ThrowingInteractorSpy())
        let soundIO = SoundIO(soundInput: "input", soundOutput: "output1", ringtoneOutput: "output2")

        sut.viewDidChangeSoundIO(
            input: soundIO.soundInput, output: soundIO.soundOutput, ringtoneOutput: soundIO.ringtoneOutput
        )

        XCTAssertEqual(factorySpy.invokedSoundIO, soundIO)
        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesUserAgentSoundIOSelectionInteractorOnSoundIOChange() {
        let interactorSpy = ThrowingInteractorSpy()
        factorySpy.stubWithUserAgentSoundIOSelectionInteractor(interactorSpy)
        factorySpy.stubWithUserDefaultsSoundIOSaveInteractor(InteractorSpy())

        sut.viewDidChangeSoundIO(input: "any-input", output: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesRingtoneOutputUpdateInteractorOnSoundIOChange() {
        factorySpy.stubWithUserAgentSoundIOSelectionInteractor(ThrowingInteractorSpy())
        factorySpy.stubWithUserDefaultsSoundIOSaveInteractor(InteractorSpy())

        sut.viewDidChangeSoundIO(input: "any-input", output: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(ringtoneOutputUpdateSpy.didCallExecute)
    }

    func testExecutesUserDefaultsRingtoneSoundNameSaveInteractorWithExpectedArgumentsOnRingtoneNameChange() {
        let interactorSpy = InteractorSpy()
        factorySpy.stubWithUserDefaultsRingtoneSoundNameSaveInteractor(interactorSpy)

        sut.viewDidChangeRingtoneName("sound-name")

        XCTAssertEqual(factorySpy.invokedRingtoneSoundName, "sound-name")
        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testPlaysRingtoneSoundOnRingtoneNameChange() {
        factorySpy.stubWithUserDefaultsRingtoneSoundNameSaveInteractor(InteractorSpy())

        sut.viewDidChangeRingtoneName("any-name")

        XCTAssertTrue(soundPlaybackSpy.didCallPlay)
    }

    func testStopsPlayingRingtoneSoundOnViewWillDisappear() {
        sut.viewWillDisappear(SoundPreferencesViewSpy())

        XCTAssertTrue(soundPlaybackSpy.didCallStop)
    }
}

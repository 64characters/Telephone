//
//  DefaultSoundPreferencesViewEventTargetTests.swift
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

import UseCasesTestDoubles
import XCTest

class DefaultSoundPreferencesViewEventTargetTests: XCTestCase {
    private var factory: InteractorFactorySpy!
    private var userAgentSoundIOSelection: InteractorSpy!
    private var ringtoneOutputUpdate: ThrowingInteractorSpy!
    private var soundPlayback: SoundPlaybackInteractorSpy!
    private var sut: DefaultSoundPreferencesViewEventTarget!

    override func setUp() {
        super.setUp()
        factory = InteractorFactorySpy()
        userAgentSoundIOSelection = InteractorSpy()
        ringtoneOutputUpdate = ThrowingInteractorSpy()
        soundPlayback = SoundPlaybackInteractorSpy()
        sut = DefaultSoundPreferencesViewEventTarget(
            interactorFactory: factory,
            presenterFactory: PresenterFactory(),
            userAgentSoundIOSelection: userAgentSoundIOSelection,
            ringtoneOutputUpdate: ringtoneOutputUpdate,
            ringtoneSoundPlayback: soundPlayback
        )
    }

    func testExecutesUserDefaultsSoundIOLoadInteractorOnViewDataReload() {
        let interactor = ThrowingInteractorSpy()
        factory.stubWithUserDefaultsSoundIOLoad(interactor)

        sut.viewShouldReloadData(SoundPreferencesViewSpy())

        XCTAssertTrue(interactor.didCallExecute)
    }

    func testExecutesUserDefaultsSoundIOLoadInteractorOnSoundIOReload() {
        let interactor = ThrowingInteractorSpy()
        factory.stubWithUserDefaultsSoundIOLoad(interactor)

        sut.viewShouldReloadSoundIO(SoundPreferencesViewSpy())

        XCTAssertTrue(interactor.didCallExecute)
    }

    func testExecutesUserDefaultsSoundIOSaveInteractorWithExpectedArgumentsOnSoundIOChange() {
        let interactor = InteractorSpy()
        factory.stubWithUserDefaultsSoundIOSave(interactor)
        factory.stubWithUserAgentSoundIOSelection(ThrowingInteractorSpy())
        let soundIO = PresentationSoundIO(input: "input", output: "output1", ringtoneOutput: "output2")

        sut.viewDidChangeSoundIO(
            input: soundIO.input, output: soundIO.output, ringtoneOutput: soundIO.ringtoneOutput
        )

        XCTAssertEqual(factory.invokedSoundIO, soundIO)
        XCTAssertTrue(interactor.didCallExecute)
    }

    func testExecutesUserAgentSoundIOSelectionInteractorOnSoundIOChange() {
        factory.stubWithUserDefaultsSoundIOSave(InteractorSpy())

        sut.viewDidChangeSoundIO(input: "any-input", output: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(userAgentSoundIOSelection.didCallExecute)
    }

    func testExecutesRingtoneOutputUpdateInteractorOnSoundIOChange() {
        factory.stubWithUserAgentSoundIOSelection(ThrowingInteractorSpy())
        factory.stubWithUserDefaultsSoundIOSave(InteractorSpy())

        sut.viewDidChangeSoundIO(input: "any-input", output: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(ringtoneOutputUpdate.didCallExecute)
    }

    func testExecutesUserDefaultsRingtoneSoundNameSaveInteractorWithExpectedArgumentsOnRingtoneNameChange() {
        let interactor = InteractorSpy()
        factory.stubWithUserDefaultsRingtoneSoundNameSave(interactor)

        sut.viewDidChangeRingtoneName("sound-name")

        XCTAssertEqual(factory.invokedRingtoneSoundName, "sound-name")
        XCTAssertTrue(interactor.didCallExecute)
    }

    func testPlaysRingtoneSoundOnRingtoneNameChange() {
        factory.stubWithUserDefaultsRingtoneSoundNameSave(InteractorSpy())

        sut.viewDidChangeRingtoneName("any-name")

        XCTAssertTrue(soundPlayback.didCallPlay)
    }

    func testStopsPlayingRingtoneSoundOnViewWillDisappear() {
        sut.viewWillDisappear(SoundPreferencesViewSpy())

        XCTAssertTrue(soundPlayback.didCallStop)
    }
}

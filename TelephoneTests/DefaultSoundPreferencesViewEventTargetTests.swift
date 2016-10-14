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

final class DefaultSoundPreferencesViewEventTargetTests: XCTestCase {
    private var factory: UseCaseFactorySpy!
    private var userAgentSoundIOSelection: UseCaseSpy!
    private var ringtoneOutputUpdate: ThrowingUseCaseSpy!
    private var soundPlayback: SoundPlaybackUseCaseSpy!
    private var sut: DefaultSoundPreferencesViewEventTarget!

    override func setUp() {
        super.setUp()
        factory = UseCaseFactorySpy()
        userAgentSoundIOSelection = UseCaseSpy()
        ringtoneOutputUpdate = ThrowingUseCaseSpy()
        soundPlayback = SoundPlaybackUseCaseSpy()
        sut = DefaultSoundPreferencesViewEventTarget(
            useCaseFactory: factory,
            presenterFactory: PresenterFactory(),
            userAgentSoundIOSelection: userAgentSoundIOSelection,
            ringtoneOutputUpdate: ringtoneOutputUpdate,
            ringtoneSoundPlayback: soundPlayback
        )
    }

    func testExecutesSettingsSoundIOLoadUseCaseOnViewDataReload() {
        let useCase = ThrowingUseCaseSpy()
        factory.stub(withSettingsSoundIOLoad: useCase)

        sut.viewShouldReloadData(SoundPreferencesViewSpy())

        XCTAssertTrue(useCase.didCallExecute)
    }

    func testExecutesSettingsSoundIOLoadUseCaseOnSoundIOReload() {
        let useCase = ThrowingUseCaseSpy()
        factory.stub(withSettingsSoundIOLoad: useCase)

        sut.viewShouldReloadSoundIO(SoundPreferencesViewSpy())

        XCTAssertTrue(useCase.didCallExecute)
    }

    func testExecutesSettingsSoundIOSaveUseCaseWithExpectedArgumentsOnSoundIOChange() {
        let useCase = UseCaseSpy()
        factory.stub(withSettingsSoundIOSave: useCase)
        let soundIO = PresentationSoundIO(input: "input", output: "output1", ringtoneOutput: "output2")

        sut.viewDidChangeSoundIO(
            input: soundIO.input, output: soundIO.output, ringtoneOutput: soundIO.ringtoneOutput
        )

        XCTAssertEqual(factory.invokedSoundIO, soundIO)
        XCTAssertTrue(useCase.didCallExecute)
    }

    func testExecutesUserAgentSoundIOSelectionUseCaseOnSoundIOChange() {
        factory.stub(withSettingsSoundIOSave: UseCaseSpy())

        sut.viewDidChangeSoundIO(input: "any-input", output: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(userAgentSoundIOSelection.didCallExecute)
    }

    func testExecutesRingtoneOutputUpdateUseCaseOnSoundIOChange() {
        factory.stub(withSettingsSoundIOSave: UseCaseSpy())

        sut.viewDidChangeSoundIO(input: "any-input", output: "any-output", ringtoneOutput: "any-output")

        XCTAssertTrue(ringtoneOutputUpdate.didCallExecute)
    }

    func testExecutesSettingsRingtoneSoundNameSaveUseCaseWithExpectedArgumentsOnRingtoneNameChange() {
        let useCase = UseCaseSpy()
        factory.stub(withSettingsRingtoneSoundNameSave: useCase)

        sut.viewDidChangeRingtoneName("sound-name")

        XCTAssertEqual(factory.invokedRingtoneSoundName, "sound-name")
        XCTAssertTrue(useCase.didCallExecute)
    }

    func testPlaysRingtoneSoundOnRingtoneNameChange() {
        factory.stub(withSettingsRingtoneSoundNameSave: UseCaseSpy())

        sut.viewDidChangeRingtoneName("any-name")

        XCTAssertTrue(soundPlayback.didCallPlay)
    }

    func testStopsPlayingRingtoneSoundOnViewWillDisappear() {
        sut.viewWillDisappear(SoundPreferencesViewSpy())

        XCTAssertTrue(soundPlayback.didCallStop)
    }
}

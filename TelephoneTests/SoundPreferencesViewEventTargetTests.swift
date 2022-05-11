//
//  SoundPreferencesViewEventTargetTests.swift
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

final class SoundPreferencesViewEventTargetTests: XCTestCase {
    private var factory: UseCaseFactorySpy!
    private var userAgentSoundIOSelection: UseCaseSpy!
    private var ringtoneOutputUpdate: ThrowingUseCaseSpy!
    private var soundPlayback: SoundPlaybackUseCaseSpy!
    private var sut: SoundPreferencesViewEventTarget!

    override func setUp() {
        super.setUp()
        factory = UseCaseFactorySpy()
        userAgentSoundIOSelection = UseCaseSpy()
        ringtoneOutputUpdate = ThrowingUseCaseSpy()
        soundPlayback = SoundPlaybackUseCaseSpy()
        sut = SoundPreferencesViewEventTarget(
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

        sut.shouldReloadData(in: SoundPreferencesViewSpy())

        XCTAssertTrue(useCase.didCallExecute)
    }

    func testExecutesSettingsSoundIOLoadUseCaseOnSoundIOReload() {
        let useCase = ThrowingUseCaseSpy()
        factory.stub(withSettingsSoundIOLoad: useCase)

        sut.shouldReloadSoundIO(in: SoundPreferencesViewSpy())

        XCTAssertTrue(useCase.didCallExecute)
    }

    func testExecutesSettingsSoundIOSaveUseCaseWithExpectedArgumentOnSoundIOChange() {
        let useCase = UseCaseSpy()
        factory.stub(withSettingsSoundIOSave: useCase)
        let soundIO = makePresentationSoundIO()

        sut.didChangeSoundIO(soundIO)

        XCTAssertEqual(factory.invokedSoundIO, SystemDefaultingSoundIO(soundIO))
        XCTAssertTrue(useCase.didCallExecute)
    }

    func testExecutesUserAgentSoundIOSelectionUseCaseOnSoundIOChange() {
        factory.stub(withSettingsSoundIOSave: UseCaseSpy())

        sut.didChangeSoundIO(makePresentationSoundIO())

        XCTAssertTrue(userAgentSoundIOSelection.didCallExecute)
    }

    func testExecutesRingtoneOutputUpdateUseCaseOnSoundIOChange() {
        factory.stub(withSettingsSoundIOSave: UseCaseSpy())

        sut.didChangeSoundIO(makePresentationSoundIO())

        XCTAssertTrue(ringtoneOutputUpdate.didCallExecute)
    }

    func testExecutesSettingsRingtoneSoundNameSaveUseCaseWithExpectedArgumentsOnRingtoneNameChange() {
        let useCase = UseCaseSpy()
        factory.stub(withSettingsRingtoneSoundNameSave: useCase)

        sut.didChangeRingtoneName("sound-name")

        XCTAssertEqual(factory.invokedRingtoneSoundName, "sound-name")
        XCTAssertTrue(useCase.didCallExecute)
    }

    func testPlaysRingtoneSoundOnRingtoneNameChange() {
        factory.stub(withSettingsRingtoneSoundNameSave: UseCaseSpy())

        sut.didChangeRingtoneName("any-name")

        XCTAssertTrue(soundPlayback.didCallPlay)
    }

    func testStopsPlayingRingtoneSoundOnViewWillDisappear() {
        sut.willDisappear(SoundPreferencesViewSpy())

        XCTAssertTrue(soundPlayback.didCallStop)
    }
}

private func makePresentationSoundIO() -> PresentationSoundIO {
    return PresentationSoundIO(
        input: PresentationAudioDevice(isSystemDefault: false, name: "any-input"),
        output: PresentationAudioDevice(isSystemDefault: false, name: "any-output"),
        ringtoneOutput: PresentationAudioDevice(isSystemDefault: false, name: "other-output")
    )
}

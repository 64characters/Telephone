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

import Testing
import UseCases
import UseCasesTestDoubles

@MainActor
struct SoundPreferencesViewEventTargetTests {
    private let factory = UseCaseFactorySpy()
    private let userAgentSoundIOSelection = UseCaseSpy()
    private let ringtoneOutputUpdate = ThrowingUseCaseSpy()
    private let soundPlayback = SoundPlaybackUseCaseSpy()
    private let sut: SoundPreferencesViewEventTarget

    init() {
        sut = SoundPreferencesViewEventTarget(
            useCaseFactory: factory,
            presenterFactory: PresenterFactory(),
            userAgentSoundIOSelection: userAgentSoundIOSelection,
            ringtoneOutputUpdate: ringtoneOutputUpdate,
            ringtoneSoundPlayback: soundPlayback
        )
    }

    @Test func executesSettingsSoundIOLoadUseCaseOnViewDataReload() {
        let useCase = ThrowingUseCaseSpy()
        factory.stub(withSettingsSoundIOLoad: useCase)

        sut.shouldReloadData(in: SoundPreferencesViewSpy())

        #expect(useCase.didCallExecute)
    }

    @Test func executesSettingsSoundIOLoadUseCaseOnSoundIOReload() {
        let useCase = ThrowingUseCaseSpy()
        factory.stub(withSettingsSoundIOLoad: useCase)

        sut.shouldReloadSoundIO(in: SoundPreferencesViewSpy())

        #expect(useCase.didCallExecute)
    }

    @Test func executesSettingsSoundIOSaveUseCaseWithExpectedArgumentOnSoundIOChange() {
        let useCase = UseCaseSpy()
        factory.stub(withSettingsSoundIOSave: useCase)
        let soundIO = makePresentationSoundIO()

        sut.didChangeSoundIO(soundIO)

        #expect(factory.invokedSoundIO == SystemDefaultingSoundIO(soundIO))
        #expect(useCase.didCallExecute)
    }

    @Test func executesUserAgentSoundIOSelectionUseCaseOnSoundIOChange() {
        factory.stub(withSettingsSoundIOSave: UseCaseSpy())

        sut.didChangeSoundIO(makePresentationSoundIO())

        #expect(userAgentSoundIOSelection.didCallExecute)
    }

    @Test func executesRingtoneOutputUpdateUseCaseOnSoundIOChange() {
        factory.stub(withSettingsSoundIOSave: UseCaseSpy())

        sut.didChangeSoundIO(makePresentationSoundIO())

        #expect(ringtoneOutputUpdate.didCallExecute)
    }

    @Test func executesSettingsRingtoneSoundNameSaveUseCaseWithExpectedArgumentsOnRingtoneNameChange() {
        let useCase = UseCaseSpy()
        factory.stub(withSettingsRingtoneSoundNameSave: useCase)

        sut.didChangeRingtoneName("sound-name")

        #expect(factory.invokedRingtoneSoundName == "sound-name")
        #expect(useCase.didCallExecute)
    }

    @Test func playsRingtoneSoundOnRingtoneNameChange() {
        factory.stub(withSettingsRingtoneSoundNameSave: UseCaseSpy())

        sut.didChangeRingtoneName("any-name")

        #expect(soundPlayback.didCallPlay)
    }

    @Test func stopsPlayingRingtoneSoundOnViewWillDisappear() {
        sut.willDisappear(SoundPreferencesViewSpy())

        #expect(soundPlayback.didCallStop)
    }
}

private func makePresentationSoundIO() -> PresentationSoundIO {
    return PresentationSoundIO(
        input: PresentationAudioDevice(isSystemDefault: false, name: "any-input"),
        output: PresentationAudioDevice(isSystemDefault: false, name: "any-output"),
        ringtoneOutput: PresentationAudioDevice(isSystemDefault: false, name: "other-output")
    )
}

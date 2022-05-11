//
//  SoundPreferencesViewEventTarget.swift
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

final class SoundPreferencesViewEventTarget: NSObject {
    private let useCaseFactory: UseCaseFactory
    private let presenterFactory: PresenterFactory
    private let userAgentSoundIOSelection: UseCase
    private let ringtoneOutputUpdate: ThrowingUseCase
    private let ringtoneSoundPlayback: SoundPlaybackUseCase

    init(useCaseFactory: UseCaseFactory,
         presenterFactory: PresenterFactory,
         userAgentSoundIOSelection: UseCase,
         ringtoneOutputUpdate: ThrowingUseCase,
         ringtoneSoundPlayback: SoundPlaybackUseCase) {
        self.useCaseFactory = useCaseFactory
        self.presenterFactory = presenterFactory
        self.userAgentSoundIOSelection = userAgentSoundIOSelection
        self.ringtoneOutputUpdate = ringtoneOutputUpdate
        self.ringtoneSoundPlayback = ringtoneSoundPlayback
    }

    @objc(viewShouldReloadData:)
    func shouldReloadData(in view: SoundPreferencesView) {
        loadSettingsSoundIOInViewOrLogError(view: view)
    }

    @objc(viewShouldReloadSoundIO:)
    func shouldReloadSoundIO(in view: SoundPreferencesView) {
        loadSettingsSoundIOInViewOrLogError(view: view)
    }

    @objc(viewDidChangeSoundIO:)
    func didChangeSoundIO(_ soundIO: PresentationSoundIO) {
        updateSettings(withSoundIO: soundIO)
        userAgentSoundIOSelection.execute()
        updateRingtoneOutputOrLogError()
    }

    @objc(viewDidChangeRingtoneName:)
    func didChangeRingtoneName(_ name: String) {
        updateSettings(withRingtoneSoundName: name)
        playRingtoneSoundOrLogError()
    }

    @objc(viewWillDisappear:)
    func willDisappear(_ view: SoundPreferencesView) {
        ringtoneSoundPlayback.stop()
    }
}

private extension SoundPreferencesViewEventTarget {
    func loadSettingsSoundIOInViewOrLogError(view: SoundPreferencesView) {
        do {
            try makeSettingsSoundIOLoadUseCase(view: view).execute()
        } catch {
            print("Could not load Sound IO view data")
        }
    }

    func updateSettings(withSoundIO soundIO: PresentationSoundIO) {
        useCaseFactory.makeSettingsSoundIOSaveUseCase(soundIO: SystemDefaultingSoundIO(soundIO)).execute()
    }

    func updateRingtoneOutputOrLogError() {
        do {
            try ringtoneOutputUpdate.execute()
        } catch {
            print("Could not update ringtone output: \(error)")
        }
    }

    func updateSettings(withRingtoneSoundName name: String) {
        useCaseFactory.makeSettingsRingtoneSoundNameSaveUseCase(name: name).execute()
    }

    func playRingtoneSoundOrLogError() {
        do {
            try ringtoneSoundPlayback.play()
        } catch {
            print("Could not play ringtone sound: \(error)")
        }
    }

    func makeSettingsSoundIOLoadUseCase(view: SoundPreferencesView) -> ThrowingUseCase {
        return useCaseFactory.makeSettingsSoundIOLoadUseCase(
            output: presenterFactory.makeSoundIOPresenter(output: view)
        )
    }
}

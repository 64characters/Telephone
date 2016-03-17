//
//  SoundPreferencesViewEventHandler.swift
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

import UseCases

class SoundPreferencesViewEventHandler: NSObject {
    let interactorFactory: InteractorFactory
    let presenterFactory: PresenterFactory
    let ringtoneOutputUpdateInteractor: ThrowingInteractor
    let ringtoneSoundPlaybackInteractor: SoundPlaybackInteractor
    let userAgent: UserAgent

    init(interactorFactory: InteractorFactory,
        presenterFactory: PresenterFactory,
        ringtoneOutputUpdateInteractor: ThrowingInteractor,
        ringtoneSoundPlaybackInteractor: SoundPlaybackInteractor,
        userAgent: UserAgent) {
            self.interactorFactory = interactorFactory
            self.presenterFactory = presenterFactory
            self.ringtoneOutputUpdateInteractor = ringtoneOutputUpdateInteractor
            self.ringtoneSoundPlaybackInteractor = ringtoneSoundPlaybackInteractor
            self.userAgent = userAgent
    }
}

extension SoundPreferencesViewEventHandler: SoundPreferencesViewObserver {
    func viewShouldReloadData(view: SoundPreferencesView) {
        let interactor = interactorFactory.createUserDefaultsSoundIOLoadInteractor(
            output: presenterFactory.createSoundIOPresenter(output: view)
        )
        do {
            try interactor.execute()
        } catch {
            print("Could not load Sound IO view data")
        }
    }

    func viewDidChangeSoundInput(soundInput: String, soundOutput: String, ringtoneOutput: String) {
        updateUserDefaultsWithSoundIO(SoundIO(soundInput: soundInput, soundOutput: soundOutput, ringtoneOutput: ringtoneOutput))
        selectUserAgentAudioDevicesOrLogError()
        updateRingtoneOutputOrLogError()
    }

    func viewDidChangeRingtoneName(name: String) {
        interactorFactory.createUserDefaultsRingtoneSoundNameSaveInteractor(name: name).execute()
        playRingtoneSoundOrLogError()
    }

    func viewWillDisappear(view: SoundPreferencesView) {
        ringtoneSoundPlaybackInteractor.stop()
    }

    private func updateUserDefaultsWithSoundIO(soundIO: SoundIO) {
        interactorFactory.createUserDefaultsSoundIOSaveInteractor(soundIO: soundIO).execute()
    }

    private func selectUserAgentAudioDevicesOrLogError() {
        do {
            try interactorFactory.createUserAgentSoundIOSelectionInteractor(userAgent: userAgent).execute()
        } catch {
            print("Could not select user agent audio devices: \(error)")
        }
    }

    private func updateRingtoneOutputOrLogError() {
        do {
            try ringtoneOutputUpdateInteractor.execute()
        } catch {
            print("Could not update ringtone output: \(error)")
        }
    }

    private func playRingtoneSoundOrLogError() {
        do {
            try ringtoneSoundPlaybackInteractor.play()
        } catch {
            print("Could not play ringtone sound: \(error)")
        }
    }
}

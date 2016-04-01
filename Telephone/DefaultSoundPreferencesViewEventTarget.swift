//
//  DefaultSoundPreferencesViewEventTarget.swift
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

class DefaultSoundPreferencesViewEventTarget: NSObject {
    let interactorFactory: InteractorFactory
    let presenterFactory: PresenterFactory
    let ringtoneOutputUpdate: ThrowingInteractor
    let ringtoneSoundPlayback: SoundPlaybackInteractor
    let userAgent: UserAgent

    init(interactorFactory: InteractorFactory,
        presenterFactory: PresenterFactory,
        ringtoneOutputUpdate: ThrowingInteractor,
        ringtoneSoundPlayback: SoundPlaybackInteractor,
        userAgent: UserAgent) {
            self.interactorFactory = interactorFactory
            self.presenterFactory = presenterFactory
            self.ringtoneOutputUpdate = ringtoneOutputUpdate
            self.ringtoneSoundPlayback = ringtoneSoundPlayback
            self.userAgent = userAgent
    }
}

extension DefaultSoundPreferencesViewEventTarget: SoundPreferencesViewEventTarget {
    func viewShouldReloadData(view: SoundPreferencesView) {
        loadUserDefaultsSoundIOInViewOrLogError(view)
    }

    func viewShouldReloadSoundIO(view: SoundPreferencesView) {
        loadUserDefaultsSoundIOInViewOrLogError(view)
    }

    func viewDidChangeSoundIO(input input: String, output: String, ringtoneOutput: String) {
        updateUserDefaultsWithSoundIO(
            PresentationSoundIO(input: input, output: output, ringtoneOutput: ringtoneOutput)
        )
        selectUserAgentAudioDevicesOrLogError()
        updateRingtoneOutputOrLogError()
    }

    func viewDidChangeRingtoneName(name: String) {
        updateUserDefaultsWithRingtoneSoundName(name)
        playRingtoneSoundOrLogError()
    }

    func viewWillDisappear(view: SoundPreferencesView) {
        ringtoneSoundPlayback.stop()
    }

    private func loadUserDefaultsSoundIOInViewOrLogError(view: SoundPreferencesView) {
        do {
            try createUserDefaultsSoundIOLoadInteractor(view: view).execute()
        } catch {
            print("Could not load Sound IO view data")
        }
    }

    private func updateUserDefaultsWithSoundIO(soundIO: PresentationSoundIO) {
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
            try ringtoneOutputUpdate.execute()
        } catch {
            print("Could not update ringtone output: \(error)")
        }
    }

    private func updateUserDefaultsWithRingtoneSoundName(name: String) {
        interactorFactory.createUserDefaultsRingtoneSoundNameSaveInteractor(name: name).execute()
    }

    private func playRingtoneSoundOrLogError() {
        do {
            try ringtoneSoundPlayback.play()
        } catch {
            print("Could not play ringtone sound: \(error)")
        }
    }

    private func createUserDefaultsSoundIOLoadInteractor(view view: SoundPreferencesView) -> ThrowingInteractor {
        return interactorFactory.createUserDefaultsSoundIOLoadInteractor(
            output: presenterFactory.createSoundIOPresenter(output: view)
        )
    }
}

//
//  SoundIOPresenter.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

class SoundIOPresenter {
    let output: SoundIOPresenterOutput

    init(output: SoundIOPresenterOutput) {
        self.output = output
    }
}

extension SoundIOPresenter: UserDefaultsSoundIOLoadInteractorOutput {
    func update(audioDevices: AudioDevices, soundIO: SoundIO) {
        output.setInputAudioDevices(audioDevices.inputDevices)
        output.setOutputAudioDevices(audioDevices.outputDevices)
        output.setRingtoneOutputAudioDevices(audioDevices.outputDevices)
        output.setSoundInputDevice(soundIO.soundInput)
        output.setSoundOutputDevice(soundIO.soundOutput)
        output.setRingtoneOutputDevice(soundIO.ringtoneOutput)
    }
}

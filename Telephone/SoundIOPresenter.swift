//
//  SoundIOPresenter.swift
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

import UseCases

class SoundIOPresenter {
    private let output: SoundIOPresenterOutput

    init(output: SoundIOPresenterOutput) {
        self.output = output
    }
}

extension SoundIOPresenter: UserDefaultsSoundIOLoadInteractorOutput {
    func update(devices devices: AudioDevices, soundIO: PresentationSoundIO) {
        output.setInputDevices(devices.input)
        output.setOutputDevices(devices.output)
        output.setRingtoneDevices(devices.output)
        output.setInputDevice(soundIO.input)
        output.setOutputDevice(soundIO.output)
        output.setRingtoneDevice(soundIO.ringtoneOutput)
    }
}

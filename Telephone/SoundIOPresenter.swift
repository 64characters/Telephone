//
//  SoundIOPresenter.swift
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

import Domain
import UseCases

final class SoundIOPresenter {
    private let output: SoundIOPresenterOutput

    init(output: SoundIOPresenterOutput) {
        self.output = output
    }
}

extension SoundIOPresenter: SettingsSoundIOLoadUseCaseOutput {
    func update(soundIO: SystemDefaultingSoundIO, devices: SystemAudioDevices) {
        let systemDefault = PresentationAudioDevice(isSystemDefault: true, name: systemDefaultDeviceName)
        output.update(
            soundIO: PresentationSoundIO(soundIO: soundIO, systemDefaultDeviceName: systemDefaultDeviceName),
            devices: PresentationAudioDevices(
                input: [systemDefault] + devices.input.map(PresentationAudioDevice.init),
                output: [systemDefault] + devices.output.map(PresentationAudioDevice.init)
            )
        )
    }
}

private let systemDefaultDeviceName = NSLocalizedString("Use System Setting", comment: "Audio device menu item.")

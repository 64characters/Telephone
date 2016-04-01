//
//  PreferredSoundIO.swift
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

import Domain

struct PreferredSoundIO {
    let devices: SystemAudioDevices
    let userDefaults: UserDefaults

    private let soundIO: SoundIO

    init(devices: SystemAudioDevices, userDefaults: UserDefaults) {
        self.devices = devices
        self.userDefaults = userDefaults
        soundIO = FallingBackSoundIO(
            origin: UserDefaultsSoundIO(devices: devices, userDefaults: userDefaults),
            fallback: Domain.PreferredSoundIO(devices: devices.all)
        )
    }
}

extension PreferredSoundIO: SoundIO {
    var input: SystemAudioDevice {
        return soundIO.input
    }

    var output: SystemAudioDevice {
        return soundIO.output
    }

    var ringtoneOutput: SystemAudioDevice {
        return soundIO.ringtoneOutput
    }
}

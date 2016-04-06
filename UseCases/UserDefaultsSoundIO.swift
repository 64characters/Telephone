//
//  UserDefaultsSoundIO.swift
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

import Domain

struct UserDefaultsSoundIO {
    let devices: SystemAudioDevices
    let userDefaults: UserDefaults

    private var optionalInput: SystemAudioDevice!
    private var optionalOutput: SystemAudioDevice!
    private var optionalRingtoneOutput: SystemAudioDevice!

    init(devices: SystemAudioDevices, userDefaults: UserDefaults) {
        self.devices = devices
        self.userDefaults = userDefaults
        optionalInput = inputDeviceByNameWithUserDefaultsKey(kSoundInput)
        optionalOutput = outputDeviceByNameWithUserDefaultsKey(kSoundOutput)
        optionalRingtoneOutput = outputDeviceByNameWithUserDefaultsKey(kRingtoneOutput)
    }

    private func inputDeviceByNameWithUserDefaultsKey(key: String) -> SystemAudioDevice {
        return deviceByNameWithUserDefaultsKey(key, function: devices.inputDeviceNamed)
    }

    private func outputDeviceByNameWithUserDefaultsKey(key: String) -> SystemAudioDevice {
        return deviceByNameWithUserDefaultsKey(key, function: devices.outputDeviceNamed)
    }

    private func deviceByNameWithUserDefaultsKey(key: String, function: String -> SystemAudioDevice) -> SystemAudioDevice {
        if let name = userDefaults.stringForKey(key) {
            return function(name)
        } else {
            return NullSystemAudioDevice()
        }
    }
}

extension UserDefaultsSoundIO: SoundIO {
    var input: SystemAudioDevice {
        return optionalInput
    }

    var output: SystemAudioDevice {
        return optionalOutput
    }

    var ringtoneOutput: SystemAudioDevice {
        return optionalRingtoneOutput
    }
}

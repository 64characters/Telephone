//
//  SavedSystemSoundIO.swift
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

struct SavedSystemSoundIO {
    let devices: SystemAudioDevices
    let userDefaults: UserDefaults

    private(set) var optionalInput: SystemAudioDevice!
    private(set) var optionalOutput: SystemAudioDevice!
    private(set) var optionalRingtoneOutput: SystemAudioDevice!

    init(devices: SystemAudioDevices, userDefaults: UserDefaults) {
        self.devices = devices
        self.userDefaults = userDefaults
        let preferredIO = PreferredSoundIO(devices: devices.all)
        optionalInput = or(inputDeviceByNameWithUserDefaultsKey(kSoundInput), preferredIO.input)
        optionalOutput = or(outputDeviceByNameWithUserDefaultsKey(kSoundOutput), preferredIO.output)
        optionalRingtoneOutput = or(outputDeviceByNameWithUserDefaultsKey(kRingtoneOutput), preferredIO.output)
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

extension SavedSystemSoundIO: SoundIO {
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

private func or(first: SystemAudioDevice, _ second: SystemAudioDevice) -> SystemAudioDevice {
    return first.isNil ? second : first
}

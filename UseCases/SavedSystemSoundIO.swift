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

    private(set) var input: SystemAudioDevice!
    private(set) var output: SystemAudioDevice!
    private(set) var ringtoneOutput: SystemAudioDevice!

    init(devices: SystemAudioDevices, userDefaults: UserDefaults) {
        self.devices = devices
        self.userDefaults = userDefaults
        let builtInDevices = FirstBuiltInSystemSoundIO(devices: devices.all)
        input = or(inputDeviceByNameWithUserDefaultsKey(kSoundInput), builtInDevices.input)
        output = or(outputDeviceByNameWithUserDefaultsKey(kSoundOutput), builtInDevices.output)
        ringtoneOutput = or(outputDeviceByNameWithUserDefaultsKey(kRingtoneOutput), builtInDevices.output)
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

private func or(first: SystemAudioDevice, _ second: SystemAudioDevice) -> SystemAudioDevice {
    return first.isNil ? second : first
}

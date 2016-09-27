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
    private let devices: SystemAudioDevices
    private let defaults: KeyValueUserDefaults
    fileprivate var optionalInput: SystemAudioDevice!
    fileprivate var optionalOutput: SystemAudioDevice!
    fileprivate var optionalRingtoneOutput: SystemAudioDevice!

    init(devices: SystemAudioDevices, defaults: KeyValueUserDefaults) {
        self.devices = devices
        self.defaults = defaults
        optionalInput = inputDeviceByName(withUserDefaultsKey: kSoundInput)
        optionalOutput = outputDeviceByName(withUserDefaultsKey: kSoundOutput)
        optionalRingtoneOutput = outputDeviceByName(withUserDefaultsKey: kRingtoneOutput)
    }

    private func inputDeviceByName(withUserDefaultsKey key: String) -> SystemAudioDevice {
        return deviceByName(withUserDefaultsKey: key, function: devices.inputDevice)
    }

    private func outputDeviceByName(withUserDefaultsKey key: String) -> SystemAudioDevice {
        return deviceByName(withUserDefaultsKey: key, function: devices.outputDevice)
    }

    private func deviceByName(withUserDefaultsKey key: String, function: (String) -> SystemAudioDevice) -> SystemAudioDevice {
        if let name = defaults.string(forKey: key) {
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

//
//  SettingsSoundIO.swift
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

struct SettingsSoundIO {
    private let devices: SystemAudioDevices
    private let settings: KeyValueSettings
    private var optionalInput: SystemAudioDevice!
    private var optionalOutput: SystemAudioDevice!
    private var optionalRingtoneOutput: SystemAudioDevice!

    init(devices: SystemAudioDevices, settings: KeyValueSettings) {
        self.devices = devices
        self.settings = settings
        optionalInput = inputDeviceByName(withSettingsKey: SettingsKeys.soundInput)
        optionalOutput = outputDeviceByName(withSettingsKey: SettingsKeys.soundOutput)
        optionalRingtoneOutput = outputDeviceByName(withSettingsKey: SettingsKeys.ringtoneOutput)
    }

    private func inputDeviceByName(withSettingsKey key: String) -> SystemAudioDevice {
        return deviceByName(withSettingsKey: key, function: devices.inputDevice)
    }

    private func outputDeviceByName(withSettingsKey key: String) -> SystemAudioDevice {
        return deviceByName(withSettingsKey: key, function: devices.outputDevice)
    }

    private func deviceByName(withSettingsKey key: String, function: (String) -> SystemAudioDevice) -> SystemAudioDevice {
        if let name = settings.string(forKey: key) {
            return function(name)
        } else {
            return NullSystemAudioDevice()
        }
    }
}

extension SettingsSoundIO: SoundIO {
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

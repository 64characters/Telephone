//
//  SelectedSystemSoundIO.swift
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

import Domain

struct SelectedSystemSoundIO {
    let systemAudioDevices: SystemAudioDevices
    let userDefaults: UserDefaults

    private(set) var soundInput: SystemAudioDevice!
    private(set) var soundOutput: SystemAudioDevice!
    private(set) var ringtoneOutput: SystemAudioDevice!

    init(systemAudioDevices: SystemAudioDevices, userDefaults: UserDefaults) throws {
        self.systemAudioDevices = systemAudioDevices
        self.userDefaults = userDefaults
        let builtInDevices = try FirstBuiltInSystemSoundIO(devices: systemAudioDevices.allDevices)
        soundInput = inputDeviceByNameWithUserDefaultsKey(kSoundInput) ?? builtInDevices.input
        soundOutput = outputDeviceByNameWithUserDefaultsKey(kSoundOutput) ?? builtInDevices.output
        ringtoneOutput = outputDeviceByNameWithUserDefaultsKey(kRingtoneOutput) ?? builtInDevices.output
    }

    private func inputDeviceByNameWithUserDefaultsKey(key: String) -> SystemAudioDevice? {
        return userDefaults.stringForKey(key).flatMap(systemAudioDevices.inputDeviceNamed)
    }

    private func outputDeviceByNameWithUserDefaultsKey(key: String) -> SystemAudioDevice? {
        return userDefaults.stringForKey(key).flatMap(systemAudioDevices.outputDeviceNamed)
    }
}

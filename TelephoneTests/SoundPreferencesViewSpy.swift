//
//  SoundPreferencesViewSpy.swift
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

class SoundPreferencesViewSpy: NSObject {
    var invokedInputAudioDevices: [String] = []
    var invokedOutputAudioDevices: [String] = []
    var invokedRingtoneOutputAudioDevices: [String] = []
    var invokedSoundInputDevice = ""
    var invokedSoundOutputDevice = ""
    var invokedRingtoneOutputDevice = ""
}

extension SoundPreferencesViewSpy: SoundPreferencesView {
    func setInputAudioDevices(devices: [String]) {
        invokedInputAudioDevices = devices
    }

    func setOutputAudioDevices(devices: [String]) {
        invokedOutputAudioDevices = devices
    }

    func setRingtoneOutputAudioDevices(devices: [String]!) {
        invokedRingtoneOutputAudioDevices = devices
    }

    func setSoundInputDevice(device: String) {
        invokedSoundInputDevice = device
    }

    func setSoundOutputDevice(device: String) {
        invokedSoundOutputDevice = device
    }

    func setRingtoneOutputDevice(device: String) {
        invokedRingtoneOutputDevice = device
    }
}

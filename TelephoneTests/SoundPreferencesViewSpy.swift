//
//  SoundPreferencesViewSpy.swift
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

class SoundPreferencesViewSpy: NSObject {
    private(set) var invokedInputDevices: [String] = []
    private(set) var invokedOutputDevices: [String] = []
    private(set) var invokedRingtoneDevices: [String] = []
    private(set) var invokedInputDevice = ""
    private(set) var invokedOutputDevice = ""
    private(set) var invokedRingtoneDevice = ""
}

extension SoundPreferencesViewSpy: SoundPreferencesView {
    func setInputDevices(devices: [String]) {
        invokedInputDevices = devices
    }

    func setOutputDevices(devices: [String]) {
        invokedOutputDevices = devices
    }

    func setRingtoneDevices(devices: [String]!) {
        invokedRingtoneDevices = devices
    }

    func setInputDevice(device: String) {
        invokedInputDevice = device
    }

    func setOutputDevice(device: String) {
        invokedOutputDevice = device
    }

    func setRingtoneDevice(device: String) {
        invokedRingtoneDevice = device
    }
}

//
//  SoundPreferencesViewSpy.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

final class SoundPreferencesViewSpy: NSObject {
    fileprivate(set) var invokedInputDevices: [String] = []
    fileprivate(set) var invokedOutputDevices: [String] = []
    fileprivate(set) var invokedRingtoneDevices: [String] = []
    fileprivate(set) var invokedInputDevice = ""
    fileprivate(set) var invokedOutputDevice = ""
    fileprivate(set) var invokedRingtoneDevice = ""
}

extension SoundPreferencesViewSpy: SoundPreferencesView {
    func setInputDevices(_ devices: [String]) {
        invokedInputDevices = devices
    }

    func setOutputDevices(_ devices: [String]) {
        invokedOutputDevices = devices
    }

    func setRingtoneDevices(_ devices: [String]!) {
        invokedRingtoneDevices = devices
    }

    func setInputDevice(_ device: String) {
        invokedInputDevice = device
    }

    func setOutputDevice(_ device: String) {
        invokedOutputDevice = device
    }

    func setRingtoneDevice(_ device: String) {
        invokedRingtoneDevice = device
    }
}

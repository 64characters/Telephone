//
//  UserAgentAudioDeviceNameToDeviceMap.swift
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

final class UserAgentAudioDeviceNameToDeviceMap {
    fileprivate let devices: [UserAgentAudioDevice]
    fileprivate var inputMap: [String: UserAgentAudioDevice] = [:]
    fileprivate var outputMap: [String: UserAgentAudioDevice] = [:]

    init(devices: [UserAgentAudioDevice]) {
        self.devices = devices
        devices.forEach(updateInputDeviceMap)
        devices.forEach(updateOutputDeviceMap)
    }

    func inputDeviceNamed(_ name: String) -> UserAgentAudioDevice {
        return inputMap[name] ?? NullUserAgentAudioDevice()
    }

    func outputDeviceNamed(_ name: String) -> UserAgentAudioDevice {
        return outputMap[name] ?? NullUserAgentAudioDevice()
    }

    fileprivate func updateInputDeviceMap(withDevice device: UserAgentAudioDevice) {
        if device.hasInputs {
            inputMap[device.name] = device
        }
    }

    fileprivate func updateOutputDeviceMap(withDevice device: UserAgentAudioDevice) {
        if device.hasOutputs {
            outputMap[device.name] = device
        }
    }
}

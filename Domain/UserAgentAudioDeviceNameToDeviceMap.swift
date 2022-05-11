//
//  UserAgentAudioDeviceNameToDeviceMap.swift
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

final class UserAgentAudioDeviceNameToDeviceMap {
    private let devices: [UserAgentAudioDevice]
    private var inputMap: [String: UserAgentAudioDevice] = [:]
    private var outputMap: [String: UserAgentAudioDevice] = [:]

    init(devices: [UserAgentAudioDevice]) {
        self.devices = devices
        devices.forEach(updateInputDeviceMap)
        devices.forEach(updateOutputDeviceMap)
    }

    func inputDevice(named name: String) -> UserAgentAudioDevice {
        return inputMap[name] ?? NullUserAgentAudioDevice()
    }

    func outputDevice(named name: String) -> UserAgentAudioDevice {
        return outputMap[name] ?? NullUserAgentAudioDevice()
    }

    private func updateInputDeviceMap(with device: UserAgentAudioDevice) {
        if device.hasInputs {
            inputMap[device.name] = device
        }
    }

    private func updateOutputDeviceMap(with device: UserAgentAudioDevice) {
        if device.hasOutputs {
            outputMap[device.name] = device
        }
    }
}

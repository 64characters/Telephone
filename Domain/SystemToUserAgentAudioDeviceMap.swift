//
//  SystemToUserAgentAudioDeviceMap.swift
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

public class SystemToUserAgentAudioDeviceMap {
    public let systemDevices: [SystemAudioDevice]
    public let userAgentDevices: [UserAgentAudioDevice]

    private var map: [SystemAudioDevice: UserAgentAudioDevice] = [:]
    private let nameToDevice: UserAgentAudioDeviceNameToDeviceMap

    public init(systemDevices: [SystemAudioDevice], userAgentDevices: [UserAgentAudioDevice]) {
        self.systemDevices = systemDevices
        self.userAgentDevices = userAgentDevices
        nameToDevice = UserAgentAudioDeviceNameToDeviceMap(devices: userAgentDevices)
        systemDevices.forEach(updateMap(withDevice:))
    }

    public func userAgentDeviceForSystemDevice(device: SystemAudioDevice) throws -> UserAgentAudioDevice {
        if let result = map[device] {
            return result
        } else {
            throw Error.SystemToUserAgentAudioDeviceMapError
        }
    }

    private func updateMap(withDevice device: SystemAudioDevice) {
        updateMap(withInputDevice: device)
        updateMap(withOutputDevice: device)
    }

    private func updateMap(withInputDevice device: SystemAudioDevice) {
        if device.hasInputs {
            if let userAgentDevice = nameToDevice.inputDeviceNamed(device.name) {
                map[device] = userAgentDevice
            }
        }
    }

    private func updateMap(withOutputDevice device: SystemAudioDevice) {
        if device.hasOutputs {
            if let userAgentDevice = nameToDevice.outputDeviceNamed(device.name) {
                map[device] = userAgentDevice
            }
        }
    }
}

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

    private var map = [SystemAudioDevice: UserAgentAudioDevice]()
    private var userAgentDeviceNameToDeviceMap = [String: UserAgentAudioDevice]()

    public init(systemDevices: [SystemAudioDevice], userAgentDevices: [UserAgentAudioDevice]) {
        self.systemDevices = systemDevices
        self.userAgentDevices = userAgentDevices
        updateMap()
    }

    public func userAgentDeviceForSystemDevice(systemDevice: SystemAudioDevice) throws -> UserAgentAudioDevice {
        if let device = map[systemDevice] {
            return device
        } else {
            throw Error.SystemToUserAgentAudioDeviceMapError
        }
    }

    private func updateMap() {
        updateUserAgentDeviceNameToDeviceMap()
        for device in systemDevices {
            updateMapWithSystemDevice(device)
        }
    }

    private func updateUserAgentDeviceNameToDeviceMap() {
        for device in userAgentDevices {
            userAgentDeviceNameToDeviceMap[device.name] = device
        }
    }

    private func updateMapWithSystemDevice(device: SystemAudioDevice) {
        if let userAgentDevice = userAgentDeviceNameToDeviceMap[device.name] {
            map[device] = userAgentDevice
        }
    }
}

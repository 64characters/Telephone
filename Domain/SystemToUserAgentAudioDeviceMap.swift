//
//  SystemToUserAgentAudioDeviceMap.swift
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

public final class SystemToUserAgentAudioDeviceMap {
    fileprivate let systemDevices: [SystemAudioDevice]
    fileprivate let userAgentDevices: [UserAgentAudioDevice]
    fileprivate var IDMap: [SystemAudioDeviceID: UserAgentAudioDeviceID] = [:]
    fileprivate let IDToUserAgentDevice: [UserAgentAudioDeviceID: UserAgentAudioDevice]
    fileprivate let nameToUserAgentDevice: UserAgentAudioDeviceNameToDeviceMap

    public init(systemDevices: [SystemAudioDevice], userAgentDevices: [UserAgentAudioDevice]) {
        self.systemDevices = systemDevices
        self.userAgentDevices = userAgentDevices
        IDToUserAgentDevice = createIDToDeviceMap(userAgentDevices)
        nameToUserAgentDevice = UserAgentAudioDeviceNameToDeviceMap(devices: userAgentDevices)
        systemDevices.forEach(updateIDMap(withDevice:))
    }

    public func userAgentDeviceForSystemDevice(_ device: SystemAudioDevice) -> UserAgentAudioDevice {
        if let deviceID = IDMap[device.identifier], let result = IDToUserAgentDevice[deviceID] {
            return result
        } else {
            return NullUserAgentAudioDevice()
        }
    }

    fileprivate func updateIDMap(withDevice device: SystemAudioDevice) {
        updateIDMap(withInputDevice: device)
        updateIDMap(withOutputDevice: device)
    }

    fileprivate func updateIDMap(withInputDevice device: SystemAudioDevice) {
        if device.hasInputs {
            let userAgentDevice = nameToUserAgentDevice.inputDeviceNamed(device.name)
            if !userAgentDevice.isNil {
                IDMap[device.identifier] = userAgentDevice.identifier
            }
        }
    }

    fileprivate func updateIDMap(withOutputDevice device: SystemAudioDevice) {
        if device.hasOutputs {
            let userAgentDevice = nameToUserAgentDevice.outputDeviceNamed(device.name)
            if !userAgentDevice.isNil {
                IDMap[device.identifier] = userAgentDevice.identifier
            }
        }
    }
}

private func createIDToDeviceMap(_ devices: [UserAgentAudioDevice]) -> [UserAgentAudioDeviceID: UserAgentAudioDevice] {
    var map: [UserAgentAudioDeviceID: UserAgentAudioDevice] = [:]
    devices.forEach({ map[$0.identifier] = $0 })
    return map
}

private typealias SystemAudioDeviceID = Int
private typealias UserAgentAudioDeviceID = Int

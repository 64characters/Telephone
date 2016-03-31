//
//  SystemToUserAgentAudioDeviceMap.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
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

    private var IDMap: [SystemAudioDeviceID: UserAgentAudioDeviceID] = [:]
    private let IDToUserAgentDevice: [UserAgentAudioDeviceID: UserAgentAudioDevice]
    private let nameToUserAgentDevice: UserAgentAudioDeviceNameToDeviceMap

    public init(systemDevices: [SystemAudioDevice], userAgentDevices: [UserAgentAudioDevice]) {
        self.systemDevices = systemDevices
        self.userAgentDevices = userAgentDevices
        IDToUserAgentDevice = createIDToDeviceMap(userAgentDevices)
        nameToUserAgentDevice = UserAgentAudioDeviceNameToDeviceMap(devices: userAgentDevices)
        systemDevices.forEach(updateIDMap(withDevice:))
    }

    public func userAgentDeviceForSystemDevice(device: SystemAudioDevice) throws -> UserAgentAudioDevice {
        if let deviceID = IDMap[device.identifier], result = IDToUserAgentDevice[deviceID] {
            return result
        } else {
            throw Error.SystemToUserAgentAudioDeviceMapError
        }
    }

    private func updateIDMap(withDevice device: SystemAudioDevice) {
        updateIDMap(withInputDevice: device)
        updateIDMap(withOutputDevice: device)
    }

    private func updateIDMap(withInputDevice device: SystemAudioDevice) {
        if device.hasInputs {
            if let userAgentDevice = nameToUserAgentDevice.inputDeviceNamed(device.name) {
                IDMap[device.identifier] = userAgentDevice.identifier
            }
        }
    }

    private func updateIDMap(withOutputDevice device: SystemAudioDevice) {
        if device.hasOutputs {
            if let userAgentDevice = nameToUserAgentDevice.outputDeviceNamed(device.name) {
                IDMap[device.identifier] = userAgentDevice.identifier
            }
        }
    }
}

private func createIDToDeviceMap(devices: [UserAgentAudioDevice]) -> [UserAgentAudioDeviceID: UserAgentAudioDevice] {
    var map: [UserAgentAudioDeviceID: UserAgentAudioDevice] = [:]
    devices.forEach({ map[$0.identifier] = $0 })
    return map
}

private typealias SystemAudioDeviceID = Int
private typealias UserAgentAudioDeviceID = Int

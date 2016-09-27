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
    private let systemDevices: [SystemAudioDevice]
    private let userAgentDevices: [UserAgentAudioDevice]
    private var IDMap: [SystemAudioDeviceID: UserAgentAudioDeviceID] = [:]
    private let IDToUserAgentDevice: [UserAgentAudioDeviceID: UserAgentAudioDevice]
    private let nameToUserAgentDevice: UserAgentAudioDeviceNameToDeviceMap

    public init(systemDevices: [SystemAudioDevice], userAgentDevices: [UserAgentAudioDevice]) {
        self.systemDevices = systemDevices
        self.userAgentDevices = userAgentDevices
        IDToUserAgentDevice = makeIDToDeviceMap(from: userAgentDevices)
        nameToUserAgentDevice = UserAgentAudioDeviceNameToDeviceMap(devices: userAgentDevices)
        systemDevices.forEach(updateIDMap(with:))
    }

    public func userAgentDevice(for device: SystemAudioDevice) -> UserAgentAudioDevice {
        if let deviceID = IDMap[device.identifier], let result = IDToUserAgentDevice[deviceID] {
            return result
        } else {
            return NullUserAgentAudioDevice()
        }
    }

    private func updateIDMap(with device: SystemAudioDevice) {
        updateIDMap(withInput: device)
        updateIDMap(withOutput: device)
    }

    private func updateIDMap(withInput device: SystemAudioDevice) {
        if device.hasInputs {
            let userAgentDevice = nameToUserAgentDevice.inputDevice(named: device.name)
            if !userAgentDevice.isNil {
                IDMap[device.identifier] = userAgentDevice.identifier
            }
        }
    }

    private func updateIDMap(withOutput device: SystemAudioDevice) {
        if device.hasOutputs {
            let userAgentDevice = nameToUserAgentDevice.outputDevice(named: device.name)
            if !userAgentDevice.isNil {
                IDMap[device.identifier] = userAgentDevice.identifier
            }
        }
    }
}

private func makeIDToDeviceMap(from devices: [UserAgentAudioDevice]) -> [UserAgentAudioDeviceID: UserAgentAudioDevice] {
    var map: [UserAgentAudioDeviceID: UserAgentAudioDevice] = [:]
    devices.forEach({ map[$0.identifier] = $0 })
    return map
}

private typealias SystemAudioDeviceID = Int
private typealias UserAgentAudioDeviceID = Int

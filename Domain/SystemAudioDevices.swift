//
//  SystemAudioDevices.swift
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

public struct SystemAudioDevices {
    public let allDevices: [SystemAudioDevice]
    public let inputDevices: [SystemAudioDevice]
    public let outputDevices: [SystemAudioDevice]

    private let deviceNameToInputDevice: [String: SystemAudioDevice]
    private let deviceNameToOutputDevice: [String: SystemAudioDevice]

    public init(devices: [SystemAudioDevice]) {
        self.allDevices = devices
        inputDevices = devices.filter({ $0.inputDevice })
        outputDevices = devices.filter({ $0.outputDevice })
        deviceNameToInputDevice = deviceNameToDeviceMapWithDevices(inputDevices)
        deviceNameToOutputDevice = deviceNameToDeviceMapWithDevices(outputDevices)
    }

    public func inputDeviceNamed(name: String) -> SystemAudioDevice? {
        return deviceNameToInputDevice[name]
    }

    public func outputDeviceNamed(name: String) -> SystemAudioDevice? {
        return deviceNameToOutputDevice[name]
    }
}

private func deviceNameToDeviceMapWithDevices(devices: [SystemAudioDevice]) -> [String: SystemAudioDevice] {
    var result = [String: SystemAudioDevice]()
    for device in devices {
        result[device.name] = device
    }
    return result
}

//
//  SystemAudioDevices.swift
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

public struct SystemAudioDevices {
    public let all: [SystemAudioDevice]
    public let input: [SystemAudioDevice]
    public let output: [SystemAudioDevice]

    fileprivate let deviceNameToInputDevice: [String: SystemAudioDevice]
    fileprivate let deviceNameToOutputDevice: [String: SystemAudioDevice]

    public init(devices: [SystemAudioDevice]) {
        self.all = devices
        input = devices.filter({ $0.hasInputs })
        output = devices.filter({ $0.hasOutputs })
        deviceNameToInputDevice = deviceNameToDeviceMapWithDevices(input)
        deviceNameToOutputDevice = deviceNameToDeviceMapWithDevices(output)
    }

    public func inputDeviceNamed(_ name: String) -> SystemAudioDevice {
        return deviceNameToInputDevice[name] ?? NullSystemAudioDevice()
    }

    public func outputDeviceNamed(_ name: String) -> SystemAudioDevice {
        return deviceNameToOutputDevice[name] ?? NullSystemAudioDevice()
    }
}

private func deviceNameToDeviceMapWithDevices(_ devices: [SystemAudioDevice]) -> [String: SystemAudioDevice] {
    var result = [String: SystemAudioDevice]()
    for device in devices {
        result[device.name] = device
    }
    return result
}

//
//  SystemAudioDevices.swift
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

public struct SystemAudioDevices {
    public let all: [SystemAudioDevice]
    public let input: [SystemAudioDevice]
    public let output: [SystemAudioDevice]

    private let deviceNameToInputDevice: [String: SystemAudioDevice]
    private let deviceNameToOutputDevice: [String: SystemAudioDevice]

    public init(devices: [SystemAudioDevice]) {
        self.all = devices
        input = devices.filter(\.hasInputs)
        output = devices.filter(\.hasOutputs)
        deviceNameToInputDevice = deviceNameToDeviceMap(from: input)
        deviceNameToOutputDevice = deviceNameToDeviceMap(from: output)
    }

    public func inputDevice(named name: String) -> SystemAudioDevice {
        return deviceNameToInputDevice[name] ?? NullSystemAudioDevice()
    }

    public func outputDevice(named name: String) -> SystemAudioDevice {
        return deviceNameToOutputDevice[name] ?? NullSystemAudioDevice()
    }
}

private func deviceNameToDeviceMap(from devices: [SystemAudioDevice]) -> [String: SystemAudioDevice] {
    return devices.reduce(into: [:]) { $0[$1.name] = $1 }
}

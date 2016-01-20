//
//  SystemAudioDeviceTestFactory.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov
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

import Domain

public class SystemAudioDeviceTestFactory {
    public let allDevices: [SystemAudioDevice]
    public let inputDevices: [SystemAudioDevice]
    public let outputDevices: [SystemAudioDevice]
    public let firstInput: SystemAudioDevice
    public let firstOutput: SystemAudioDevice
    public let firstBuiltInInput: SystemAudioDevice
    public let firstBuiltInOutput: SystemAudioDevice
    public let someInputDevice: SystemAudioDevice
    public let someOutputDevice: SystemAudioDevice
    public let inputOnlyDevice: SystemAudioDevice
    public let outputOnlyDevice: SystemAudioDevice

    public init() {
        let device1 = SystemAudioDevice(identifier: 1, uniqueIdentifier: "UID1", name: "Device1", inputCount: 1, outputCount: 0, builtIn: false)
        let device2 = SystemAudioDevice(identifier: 2, uniqueIdentifier: "UID2", name: "Device2", inputCount: 0, outputCount: 1, builtIn: false)
        let device3 = SystemAudioDevice(identifier: 3, uniqueIdentifier: "UID3", name: "Device3", inputCount: 1, outputCount: 0, builtIn: true)
        let device4 = SystemAudioDevice(identifier: 4, uniqueIdentifier: "UID4", name: "Device4", inputCount: 0, outputCount: 1, builtIn: true)
        allDevices = [device1, device2, device3, device4]
        inputDevices = [device1, device3]
        outputDevices = [device2, device4]
        firstInput = device1
        firstOutput = device2
        firstBuiltInInput = device3
        firstBuiltInOutput = device4
        someInputDevice = device1
        someOutputDevice = device2
        inputOnlyDevice = device1
        outputOnlyDevice = device2
    }
}

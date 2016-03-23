//
//  SystemAudioDeviceTestFactory.swift
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

import Domain

public class SystemAudioDeviceTestFactory {
    public let all: [SystemAudioDevice]
    public let allInput: [SystemAudioDevice]
    public let allOutput: [SystemAudioDevice]
    public let firstInput: SystemAudioDevice
    public let firstOutput: SystemAudioDevice
    public let firstBuiltInInput: SystemAudioDevice
    public let firstBuiltInOutput: SystemAudioDevice
    public let someInput: SystemAudioDevice
    public let someOutput: SystemAudioDevice
    public let inputOnly: SystemAudioDevice
    public let outputOnly: SystemAudioDevice
    public let outputWithNameLikeSomeInput: SystemAudioDevice
    public let intputAndOutput: SystemAudioDevice

    public init() {
        let device1 = SystemAudioDevice(identifier: 1, uniqueIdentifier: "UID1", name: "Device1", inputCount: 1, outputCount: 0, builtIn: false)
        let device2 = SystemAudioDevice(identifier: 2, uniqueIdentifier: "UID2", name: "Device2", inputCount: 0, outputCount: 1, builtIn: false)
        let device3 = SystemAudioDevice(identifier: 3, uniqueIdentifier: "UID3", name: "Device3", inputCount: 1, outputCount: 0, builtIn: true)
        let device4 = SystemAudioDevice(identifier: 4, uniqueIdentifier: "UID4", name: "Device4", inputCount: 0, outputCount: 1, builtIn: true)
        let device5 = SystemAudioDevice(identifier: 5, uniqueIdentifier: "UID5", name: "Device1", inputCount: 0, outputCount: 1, builtIn: false)
        let device6 = SystemAudioDevice(identifier: 6, uniqueIdentifier: "UID6", name: "Device6", inputCount: 1, outputCount: 1, builtIn: false)
        all = [device1, device2, device3, device4, device5, device6]
        allInput = [device1, device3, device6]
        allOutput = [device2, device4, device5, device6]
        firstInput = device1
        firstOutput = device2
        firstBuiltInInput = device3
        firstBuiltInOutput = device4
        someInput = device1
        someOutput = device2
        inputOnly = device3
        outputOnly = device2
        outputWithNameLikeSomeInput = device5
        intputAndOutput = device6
    }
}

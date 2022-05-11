//
//  SystemAudioDeviceTestFactory.swift
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

import Domain

public final class SystemAudioDeviceTestFactory {
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
        let device1 = SimpleSystemAudioDevice(identifier: 1, uniqueIdentifier: "UID1", name: "Device1", inputs: 1, outputs: 0, isBuiltIn: false)
        let device2 = SimpleSystemAudioDevice(identifier: 2, uniqueIdentifier: "UID2", name: "Device2", inputs: 0, outputs: 1, isBuiltIn: false)
        let device3 = SimpleSystemAudioDevice(identifier: 3, uniqueIdentifier: "UID3", name: "Device3", inputs: 1, outputs: 0, isBuiltIn: true)
        let device4 = SimpleSystemAudioDevice(identifier: 4, uniqueIdentifier: "UID4", name: "Device4", inputs: 0, outputs: 1, isBuiltIn: true)
        let device5 = SimpleSystemAudioDevice(identifier: 5, uniqueIdentifier: "UID5", name: "Device1", inputs: 0, outputs: 1, isBuiltIn: false)
        let device6 = SimpleSystemAudioDevice(identifier: 6, uniqueIdentifier: "UID6", name: "Device6", inputs: 1, outputs: 1, isBuiltIn: false)
        let device7 = SimpleSystemAudioDevice(identifier: 7, uniqueIdentifier: "UID7", name: "Device7", inputs: 1, outputs: 0, isBuiltIn: false)
        let device8 = SimpleSystemAudioDevice(identifier: 8, uniqueIdentifier: "UID8", name: "Device8", inputs: 0, outputs: 1, isBuiltIn: false)
        all = [device1, device2, device3, device4, device5, device6, device7, device8]
        allInput = [device1, device3, device6, device7]
        allOutput = [device2, device4, device5, device6, device8]
        firstInput = device1
        firstOutput = device2
        firstBuiltInInput = device3
        firstBuiltInOutput = device4
        someInput = device7
        someOutput = device8
        inputOnly = device3
        outputOnly = device2
        outputWithNameLikeSomeInput = device5
        intputAndOutput = device6
    }
}

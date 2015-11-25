//
//  SystemAudioDeviceTestFactory.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

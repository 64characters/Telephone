//
//  AudioDevicesMapTests.swift
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

import XCTest

class AudioDevicesMapTests: XCTestCase {

    func testMapsSystemToUserAgentDeviceByName() {
        let systemDevice1 = SystemAudioDevice(identifier: 1, uniqueIdentifier: "", name: "Device1", inputCount: 0, outputCount: 0, builtIn: false)
        let systemDevice2 = SystemAudioDevice(identifier: 2, uniqueIdentifier: "", name: "Device2", inputCount: 0, outputCount: 0, builtIn: false)
        let systemDevices = [systemDevice1, systemDevice2]
        let userAgentDevice1 = UserAgentAudioDevice(identifier: 1, name: "Device2")
        let userAgentDevice2 = UserAgentAudioDevice(identifier: 2, name: "Device1")
        let userAgentDecices = [userAgentDevice1, userAgentDevice2]

        let map = AudioDeviceMap(systemDevices: systemDevices, userAgentDevices: userAgentDecices)

        XCTAssertEqual(map[systemDevice1], userAgentDevice2)
        XCTAssertEqual(map[systemDevice2], userAgentDevice1)
    }
}

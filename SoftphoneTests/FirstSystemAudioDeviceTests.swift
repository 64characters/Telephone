//
//  FirstSystemAudioDeviceTests.swift
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

class FirstSystemAudioDeviceTests: XCTestCase {
    var factory: SystemAudioDeviceTestFactory!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
    }

    func testCreatedWithFirstInputDevice() {
        let device = try! FirstSystemAudioDevice(devices: factory.allDevices, predicate: { $0.inputDevice })

        XCTAssertEqual(device.device, factory.firstInput)
    }

    func testCreatedWithFirstOutputDevice() {
        let device = try! FirstSystemAudioDevice(devices: factory.allDevices, predicate: { $0.outputDevice })

        XCTAssertEqual(device.device, factory.firstOutput)
    }

    func testCreatedWithFirstBuiltInInputDevice() {
        let device = try! FirstSystemAudioDevice(devices: factory.allDevices, predicate: { $0.builtInInputDevice })

        XCTAssertEqual(device.device, factory.firstBuiltInInput)
    }

    func testCreatedWithFirstBuiltInOutputDevice() {
        let device = try! FirstSystemAudioDevice(devices: factory.allDevices, predicate: { $0.builtInOutputDevice })

        XCTAssertEqual(device.device, factory.firstBuiltInOutput)
    }

    func testThrowsSystemAudioDeviceNotFoundErrorIfNotFound() {
        var didThrow = false
        let devices = [factory.someOutputDevice, factory.firstBuiltInOutput]

        do {
            _ = try FirstSystemAudioDevice(devices: devices, predicate: {$0.inputDevice })
        } catch Error.SystemAudioDeviceNotFoundError {
            didThrow = true
        } catch {}

        XCTAssertTrue(didThrow)
    }
}

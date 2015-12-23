//
//  SelectedSystemSoundIOTests.swift
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
import DomainTestDoubles
@testable import UseCases
import UseCasesTestDoubles
import XCTest

class SelectedSystemSoundIOTests: XCTestCase {
    private var deviceFactory: SystemAudioDeviceTestFactory!
    private var systemDevices: SystemAudioDevices!
    private var userDefaults: UserDefaultsFake!

    override func setUp() {
        super.setUp()
        deviceFactory = SystemAudioDeviceTestFactory()
        systemDevices = SystemAudioDevices(devices: deviceFactory.allDevices)
        userDefaults = UserDefaultsFake()
    }

    // MARK: - Sound input

    func testSelectsAudioDeviceWithNameFromUserDefaultsAsSoundInput() {
        let someDevice = deviceFactory.someInputDevice
        userDefaults[kSoundInput] = someDevice.name

        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundInput, someDevice)
    }

    func testSelectsBuiltInAudioInputDeviceAsSoundInputIfThereIsNoSoundInputInUserDefaults() {
        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundInput, deviceFactory.firstBuiltInInput)
    }

    func testSelectsBuiltInAudioInputDeviceAsSoundInputIfSoundInputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        userDefaults[kSoundInput] = kNonexistentDeviceName

        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundInput, deviceFactory.firstBuiltInInput)
    }

    func testSelectsBuiltInAudioInputDeviceAsSoundInputIfAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveInputChannels() {
        userDefaults[kSoundInput] = deviceFactory.outputOnlyDevice.name

        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundInput, deviceFactory.firstBuiltInInput)
    }

    // MARK: - Sound output

    func testSelectsAudioDeviceWithNameFromUserDefaultsAsSoundOutput() {
        let someDevice = deviceFactory.someOutputDevice
        userDefaults[kSoundOutput] = someDevice.name

        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundOutput, someDevice)
    }

    func testSelectsBuiltInAudioOutputDeviceAsSoundOutputIfThereIsNoSoundOutputInUserDefaults() {
        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundOutput, deviceFactory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsSoundOutputIfSoundOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        userDefaults[kSoundOutput] = kNonexistentDeviceName

        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundOutput, deviceFactory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsSoundOutputIfAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        userDefaults[kSoundOutput] = deviceFactory.inputOnlyDevice.name

        let sut = createSelectedIO()

        XCTAssertEqual(sut.soundOutput, deviceFactory.firstBuiltInOutput)
    }

    // MARK: - Ringtone output

    func testSelectsAudioDeviceWithNameFromUserDefaultsAsRingtoneOutput() {
        let someDevice = deviceFactory.someOutputDevice
        userDefaults[kRingtoneOutput] = someDevice.name

        let sut = createSelectedIO()

        XCTAssertEqual(sut.ringtoneOutput, someDevice)
    }

    func testSelectsBuiltInAudioOutputDeviceAsRingtoneOutputIfThereIsNoRingtoneOutputInUserDefaults() {
        let sut = createSelectedIO()

        XCTAssertEqual(sut.ringtoneOutput, deviceFactory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsRingtoneOutputIfRingtoneOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        let sut = createSelectedIO()

        userDefaults[kRingtoneOutput] = kNonexistentDeviceName

        XCTAssertEqual(sut.ringtoneOutput, deviceFactory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsRingtoneOutputIfAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        userDefaults[kRingtoneOutput] = deviceFactory.inputOnlyDevice.name

        let sut = createSelectedIO()

        XCTAssertEqual(sut.ringtoneOutput, deviceFactory.firstBuiltInOutput)
    }

    // MARK: - Helper

    private func createSelectedIO() -> SelectedSystemSoundIO {
        return try! SelectedSystemSoundIO(systemAudioDevices: systemDevices, userDefaults: userDefaults)
    }
}

private let kNonexistentDeviceName = "Nonexistent"

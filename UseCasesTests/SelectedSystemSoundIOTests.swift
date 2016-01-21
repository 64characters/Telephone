//
//  SelectedSystemSoundIOTests.swift
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

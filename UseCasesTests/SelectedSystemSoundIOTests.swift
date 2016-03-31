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
    private var factory: SystemAudioDeviceTestFactory!
    private var userDefaults: UserDefaultsFake!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        userDefaults = UserDefaultsFake()
    }

    // MARK: - Sound input

    func testSelectsAudioDeviceWithNameFromUserDefaultsAsSoundInput() {
        let someDevice = factory.someInput
        userDefaults[kSoundInput] = someDevice.name

        let sut = createSelectedIO()

        XCTAssertTrue(sut.input == someDevice)
    }

    func testSelectsBuiltInAudioInputDeviceAsSoundInputIfThereIsNoSoundInputInUserDefaults() {
        let sut = createSelectedIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testSelectsBuiltInAudioInputDeviceAsSoundInputIfSoundInputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        userDefaults[kSoundInput] = kNonexistentDeviceName

        let sut = createSelectedIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testSelectsBuiltInAudioInputDeviceAsSoundInputIfAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveInputChannels() {
        userDefaults[kSoundInput] = factory.outputOnly.name

        let sut = createSelectedIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    // MARK: - Sound output

    func testSelectsAudioDeviceWithNameFromUserDefaultsAsSoundOutput() {
        let someDevice = factory.someOutput
        userDefaults[kSoundOutput] = someDevice.name

        let sut = createSelectedIO()

        XCTAssertTrue(sut.output == someDevice)
    }

    func testSelectsBuiltInAudioOutputDeviceAsSoundOutputIfThereIsNoSoundOutputInUserDefaults() {
        let sut = createSelectedIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsSoundOutputIfSoundOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        userDefaults[kSoundOutput] = kNonexistentDeviceName

        let sut = createSelectedIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsSoundOutputIfAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        userDefaults[kSoundOutput] = factory.inputOnly.name

        let sut = createSelectedIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    // MARK: - Ringtone output

    func testSelectsAudioDeviceWithNameFromUserDefaultsAsRingtoneOutput() {
        let someDevice = factory.someOutput
        userDefaults[kRingtoneOutput] = someDevice.name

        let sut = createSelectedIO()

        XCTAssertTrue(sut.ringtoneOutput == someDevice)
    }

    func testSelectsBuiltInAudioOutputDeviceAsRingtoneOutputIfThereIsNoRingtoneOutputInUserDefaults() {
        let sut = createSelectedIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsRingtoneOutputIfRingtoneOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        let sut = createSelectedIO()

        userDefaults[kRingtoneOutput] = kNonexistentDeviceName

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testSelectsBuiltInAudioOutputDeviceAsRingtoneOutputIfAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        userDefaults[kRingtoneOutput] = factory.inputOnly.name

        let sut = createSelectedIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    // MARK: - Helper

    private func createSelectedIO() -> SelectedSystemSoundIO {
        return try! SelectedSystemSoundIO(
            devices: SystemAudioDevices(devices: factory.all),
            userDefaults: userDefaults
        )
    }
}

private let kNonexistentDeviceName = "Nonexistent"

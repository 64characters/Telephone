//
//  PreferredSoundIOTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

final class PreferredSoundIOTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!
    private var userDefaults: UserDefaultsFake!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        userDefaults = UserDefaultsFake()
    }

    // MARK: - Sound input

    func testInputIsDeviceWithNameFromUserDefaults() {
        let someDevice = factory.someInput
        userDefaults[kSoundInput] = someDevice.name

        let sut = createSoundIO()

        XCTAssertTrue(sut.input == someDevice)
    }

    func testInputIsBuiltInInputWhenThereIsNoSoundInputInUserDefaults() {
        let sut = createSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenSoundInputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        userDefaults[kSoundInput] = kNonexistentDeviceName

        let sut = createSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveInputChannels() {
        userDefaults[kSoundInput] = factory.outputOnly.name

        let sut = createSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsFirstInputWhenNotFoundInUserDefaultsAndThereIsNoBuiltInInput() {
        let sut = createSoundIO(devices: [factory.firstInput, factory.someOutput])

        XCTAssertTrue(sut.input == factory.firstInput)
    }

    // MARK: - Sound output

    func testOutputIsDeviceWithNameFromUserDefaults() {
        let someDevice = factory.someOutput
        userDefaults[kSoundOutput] = someDevice.name

        let sut = createSoundIO()

        XCTAssertTrue(sut.output == someDevice)
    }

    func testOutputIsBuiltInOutputWhenThereIsNoSoundOutputInUserDefaults() {
        let sut = createSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenSoundOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        userDefaults[kSoundOutput] = kNonexistentDeviceName

        let sut = createSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        userDefaults[kSoundOutput] = factory.inputOnly.name

        let sut = createSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsFirstOutputWhenNotFoundInUserDefaultsAndThereIsNoBuiltInOutput() {
        let sut = createSoundIO(devices: [factory.someInput, factory.firstOutput])

        XCTAssertTrue(sut.output == factory.firstOutput)
    }

    // MARK: - Ringtone output

    func testRingtoneOutputIsDeviceWithNameFromUserDefaults() {
        let someDevice = factory.someOutput
        userDefaults[kRingtoneOutput] = someDevice.name

        let sut = createSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == someDevice)
    }

    func testRingtoneOutputIsBuiltInOutputWhenThereIsNoRingtoneOutputInUserDefaults() {
        let sut = createSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenRingtoneOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        let sut = createSoundIO()

        userDefaults[kRingtoneOutput] = kNonexistentDeviceName

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        userDefaults[kRingtoneOutput] = factory.inputOnly.name

        let sut = createSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsFirstOutputWhenNotFoundInUserDefaultsAndThereIsNoBuiltInOutput() {
        let sut = createSoundIO(devices: [factory.someInput, factory.firstOutput])

        XCTAssertTrue(sut.ringtoneOutput == factory.firstOutput)
    }

    // MARK: - Helper

    private func createSoundIO() -> UseCases.PreferredSoundIO {
        return createSoundIO(devices: factory.all)
    }

    private func createSoundIO(devices devices: [SystemAudioDevice]) -> UseCases.PreferredSoundIO {
        return PreferredSoundIO(
            devices: SystemAudioDevices(devices: devices),
            userDefaults: userDefaults
        )
    }
}

private let kNonexistentDeviceName = "Nonexistent"

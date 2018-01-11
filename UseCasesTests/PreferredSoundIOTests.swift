//
//  PreferredSoundIOTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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
    private var settings: SettingsFake!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        settings = SettingsFake()
    }

    // MARK: - Sound input

    func testInputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someInput
        settings[SettingsKeys.soundInput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == someDevice)
    }

    func testInputIsBuiltInInputWhenThereIsNoSoundInputInSettings() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenSoundInputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.soundInput] = kNonexistentDeviceName

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveInputChannels() {
        settings[SettingsKeys.soundInput] = factory.outputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsFirstInputWhenNotFoundInSettingsAndThereIsNoBuiltInInput() {
        let sut = makeSoundIO(devices: [factory.firstInput, factory.someOutput])

        XCTAssertTrue(sut.input == factory.firstInput)
    }

    // MARK: - Sound output

    func testOutputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someOutput
        settings[SettingsKeys.soundOutput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == someDevice)
    }

    func testOutputIsBuiltInOutputWhenThereIsNoSoundOutputInSettings() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenSoundOutputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.soundOutput] = kNonexistentDeviceName

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveOutputChannels() {
        settings[SettingsKeys.soundOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsFirstOutputWhenNotFoundInSettingsAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput])

        XCTAssertTrue(sut.output == factory.firstOutput)
    }

    // MARK: - Ringtone output

    func testRingtoneOutputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someOutput
        settings[SettingsKeys.ringtoneOutput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == someDevice)
    }

    func testRingtoneOutputIsBuiltInOutputWhenThereIsNoRingtoneOutputInSettings() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenRingtoneOutputFromSettingsCanNotBeFoundInSystemDevices() {
        let sut = makeSoundIO()

        settings[SettingsKeys.ringtoneOutput] = kNonexistentDeviceName

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveOutputChannels() {
        settings[SettingsKeys.ringtoneOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsFirstOutputWhenNotFoundInSettingsAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput])

        XCTAssertTrue(sut.ringtoneOutput == factory.firstOutput)
    }

    // MARK: - Helper

    private func makeSoundIO() -> UseCases.PreferredSoundIO {
        return makeSoundIO(devices: factory.all)
    }

    private func makeSoundIO(devices: [SystemAudioDevice]) -> UseCases.PreferredSoundIO {
        return PreferredSoundIO(devices: SystemAudioDevices(devices: devices), settings: settings)
    }
}

private let kNonexistentDeviceName = "Nonexistent"

//
//  PreferredSoundIOTests.swift
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

    func testInputIsDefaultInputWhenThereIsNoSoundInputInSettings() {
        let defaultIO = SimpleSystemSoundIO(input: factory.someInput, output: NullSystemAudioDevice())

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        XCTAssertTrue(sut.input == defaultIO.input)
    }

    func testInputIsDefaultInputWhenSoundInputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.soundInput] = kNonexistentDeviceName
        let defaultIO = SimpleSystemSoundIO(input: factory.someInput, output: NullSystemAudioDevice())

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        XCTAssertTrue(sut.input == defaultIO.input)
    }

    func testInputIsBuiltInInputWhenThereIsNoSoundInputInSettingsAndThereIsNoDefaultInput() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenSoundInputFromSettingsCanNotBeFoundInSystemDevicesAndThereIsNoDefaultInput() {
        settings[SettingsKeys.soundInput] = kNonexistentDeviceName

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveInputChannelsAndThereIsNoDefaultInput() {
        settings[SettingsKeys.soundInput] = factory.outputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsFirstInputWhenNotFoundInSettingsAndThereIsNoDefaultInputAndThereIsNoBuiltInInput() {
        let sut = makeSoundIO(devices: [factory.firstInput, factory.someInput, factory.someOutput])

        XCTAssertTrue(sut.input == factory.firstInput)
    }

    // MARK: - Sound output

    func testOutputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someOutput
        settings[SettingsKeys.soundOutput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == someDevice)
    }

    func testOutputIsDefaultOutputWhenThereIsNoSoundOutputInSettings() {
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        XCTAssertTrue(sut.output == defaultIO.output)
    }

    func testOutputIsDefaultOutputWhenSoundOutputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.soundOutput] = kNonexistentDeviceName
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        XCTAssertTrue(sut.output == defaultIO.output)
    }

    func testOutputIsBuiltInOutputWhenThereIsNoSoundOutputInSettingsAndThereIsNoDefaultOutput() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenSoundOutputFromSettingsCanNotBeFoundInSystemDevicesAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.soundOutput] = kNonexistentDeviceName

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveOutputChannelsAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.soundOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsFirstOutputWhenNotFoundInSettingsAndThereIsNoDefaultOutputAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput, factory.someOutput])

        XCTAssertTrue(sut.output == factory.firstOutput)
    }

    // MARK: - Ringtone output

    func testRingtoneOutputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someOutput
        settings[SettingsKeys.ringtoneOutput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == someDevice)
    }

    func testRingtoneOutputIsDefaultOutputWhenThereIsNoRingtoneOutputInSettings() {
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        XCTAssertTrue(sut.ringtoneOutput == defaultIO.output)
    }

    func testRingtoneOutputIsDefaultOutputWhenRingtoneOutputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.ringtoneOutput] = kNonexistentDeviceName
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        XCTAssertTrue(sut.ringtoneOutput == defaultIO.output)
    }

    func testRingtoneOutputIsBuiltInOutputWhenThereIsNoRingtoneOutputInSettingsAndThereIsNoDefaultOutput() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenRingtoneOutputFromSettingsCanNotBeFoundInSystemDevicesAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.ringtoneOutput] = kNonexistentDeviceName

        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveOutputChannelsAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.ringtoneOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsFirstOutputWhenNotFoundInSettingsAndThereIsNoDefaultOutputAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput, factory.someOutput])

        XCTAssertTrue(sut.ringtoneOutput == factory.firstOutput)
    }
}

private extension PreferredSoundIOTests {
    func makeSoundIO(devices: [SystemAudioDevice], settings: KeyValueSettings, defaultIO: SystemSoundIO = NullSystemSoundIO()) -> UseCases.PreferredSoundIO {
        return PreferredSoundIO(
            devices: SystemAudioDevices(devices: devices), settings: settings, defaultIO: defaultIO
        )
    }

    func makeSoundIO(devices: [SystemAudioDevice]) -> UseCases.PreferredSoundIO {
        return makeSoundIO(devices: devices, settings: settings)
    }

    func makeSoundIO() -> UseCases.PreferredSoundIO {
        return makeSoundIO(devices: factory.all)
    }
}

private let kNonexistentDeviceName = "Nonexistent"

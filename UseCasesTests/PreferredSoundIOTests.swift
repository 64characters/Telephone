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
import Testing
@testable import UseCases
import UseCasesTestDoubles

@MainActor
struct PreferredSoundIOTests {
    private let factory = SystemAudioDeviceTestFactory()
    private let settings = SettingsFake()

    // MARK: - Sound input

    @Test func inputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someInput
        settings[SettingsKeys.soundInput] = someDevice.name

        let sut = makeSoundIO()

        #expect(sut.input == someDevice)
    }

    @Test func inputIsDefaultInputWhenThereIsNoSoundInputInSettings() {
        let defaultIO = SimpleSystemSoundIO(input: factory.someInput, output: NullSystemAudioDevice())

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        #expect(sut.input == defaultIO.input)
    }

    @Test func inputIsDefaultInputWhenSoundInputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.soundInput] = nonexistentDeviceName
        let defaultIO = SimpleSystemSoundIO(input: factory.someInput, output: NullSystemAudioDevice())

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        #expect(sut.input == defaultIO.input)
    }

    @Test func inputIsBuiltInInputWhenThereIsNoSoundInputInSettingsAndThereIsNoDefaultInput() {
        let sut = makeSoundIO()

        #expect(sut.input == factory.firstBuiltInInput)
    }

    @Test func inputIsBuiltInInputWhenSoundInputFromSettingsCanNotBeFoundInSystemDevicesAndThereIsNoDefaultInput() {
        settings[SettingsKeys.soundInput] = nonexistentDeviceName

        let sut = makeSoundIO()

        #expect(sut.input == factory.firstBuiltInInput)
    }

    @Test func inputIsBuiltInInputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveInputChannelsAndThereIsNoDefaultInput() {
        settings[SettingsKeys.soundInput] = factory.outputOnly.name

        let sut = makeSoundIO()

        #expect(sut.input == factory.firstBuiltInInput)
    }

    @Test func inputIsFirstInputWhenNotFoundInSettingsAndThereIsNoDefaultInputAndThereIsNoBuiltInInput() {
        let sut = makeSoundIO(devices: [factory.firstInput, factory.someInput, factory.someOutput])

        #expect(sut.input == factory.firstInput)
    }

    // MARK: - Sound output

    @Test func outputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someOutput
        settings[SettingsKeys.soundOutput] = someDevice.name

        let sut = makeSoundIO()

        #expect(sut.output == someDevice)
    }

    @Test func outputIsDefaultOutputWhenThereIsNoSoundOutputInSettings() {
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        #expect(sut.output == defaultIO.output)
    }

    @Test func outputIsDefaultOutputWhenSoundOutputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.soundOutput] = nonexistentDeviceName
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        #expect(sut.output == defaultIO.output)
    }

    @Test func outputIsBuiltInOutputWhenThereIsNoSoundOutputInSettingsAndThereIsNoDefaultOutput() {
        let sut = makeSoundIO()

        #expect(sut.output == factory.firstBuiltInOutput)
    }

    @Test func outputIsBuiltInOutputWhenSoundOutputFromSettingsCanNotBeFoundInSystemDevicesAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.soundOutput] = nonexistentDeviceName

        let sut = makeSoundIO()

        #expect(sut.output == factory.firstBuiltInOutput)
    }

    @Test func outputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveOutputChannelsAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.soundOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        #expect(sut.output == factory.firstBuiltInOutput)
    }

    @Test func outputIsFirstOutputWhenNotFoundInSettingsAndThereIsNoDefaultOutputAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput, factory.someOutput])

        #expect(sut.output == factory.firstOutput)
    }

    // MARK: - Ringtone output

    @Test func ringtoneOutputIsDeviceWithNameFromSettings() {
        let someDevice = factory.someOutput
        settings[SettingsKeys.ringtoneOutput] = someDevice.name

        let sut = makeSoundIO()

        #expect(sut.ringtoneOutput == someDevice)
    }

    @Test func ringtoneOutputIsDefaultOutputWhenThereIsNoRingtoneOutputInSettings() {
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        #expect(sut.ringtoneOutput == defaultIO.output)
    }

    @Test func ringtoneOutputIsDefaultOutputWhenRingtoneOutputFromSettingsCanNotBeFoundInSystemDevices() {
        settings[SettingsKeys.ringtoneOutput] = nonexistentDeviceName
        let defaultIO = SimpleSystemSoundIO(input: NullSystemAudioDevice(), output: factory.someOutput)

        let sut = makeSoundIO(devices: factory.all, settings: settings, defaultIO: defaultIO)

        #expect(sut.ringtoneOutput == defaultIO.output)
    }

    @Test func ringtoneOutputIsBuiltInOutputWhenThereIsNoRingtoneOutputInSettingsAndThereIsNoDefaultOutput() {
        let sut = makeSoundIO()

        #expect(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    @Test func ringtoneOutputIsBuiltInOutputWhenRingtoneOutputFromSettingsCanNotBeFoundInSystemDevicesAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.ringtoneOutput] = nonexistentDeviceName

        let sut = makeSoundIO()

        #expect(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    @Test func ringtoneOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromSettingsDoesNotHaveOutputChannelsAndThereIsNoDefaultOutput() {
        settings[SettingsKeys.ringtoneOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        #expect(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    @Test func ringtoneOutputIsFirstOutputWhenNotFoundInSettingsAndThereIsNoDefaultOutputAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput, factory.someOutput])

        #expect(sut.ringtoneOutput == factory.firstOutput)
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

private let nonexistentDeviceName = "Nonexistent"

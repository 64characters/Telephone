//
//  SettingsSoundIOSaveUseCaseTests.swift
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
import UseCases
import UseCasesTestDoubles

@MainActor
struct SettingsSoundIOSaveUseCaseTests {
    @Test func savesDeviceNamesInSettingsWhenSoundIOIsNormalDevices() {
        let input = "any-input"
        let output = "any-output"
        let ringtoneOutput = "other-output"
        let settings = SettingsFake()
        let sut = SettingsSoundIOSaveUseCase(
            soundIO: SystemDefaultingSoundIO(
                input: .device(name: input),
                output: .device(name: output),
                ringtoneOutput: .device(name: ringtoneOutput)
            ),
            settings: settings
        )

        sut.execute()

        #expect(settings[SettingsKeys.soundInput] == input)
        #expect(settings[SettingsKeys.soundOutput] == output)
        #expect(settings[SettingsKeys.ringtoneOutput] == ringtoneOutput)
    }

    @Test func deletesDeviceNamesFromSettingsWhenSoundIOIsSystemDefaultDevices() {
        let settings = SettingsFake()
        settings[SettingsKeys.soundInput] = "any-value"
        settings[SettingsKeys.soundOutput] = "any-value"
        settings[SettingsKeys.ringtoneOutput] = "any-value"
        let sut = SettingsSoundIOSaveUseCase(
            soundIO: SystemDefaultingSoundIO(
                input: .systemDefault, output: .systemDefault, ringtoneOutput: .systemDefault
            ),
            settings: settings
        )

        sut.execute()

        #expect(settings[SettingsKeys.soundInput] == nil)
        #expect(settings[SettingsKeys.soundOutput] == nil)
        #expect(settings[SettingsKeys.ringtoneOutput] == nil)
    }
}

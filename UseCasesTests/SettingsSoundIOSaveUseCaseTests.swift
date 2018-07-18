//
//  SettingsSoundIOSaveUseCaseTests.swift
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

@testable import Domain
import DomainTestDoubles
@testable import UseCases
import UseCasesTestDoubles
import XCTest

final class SettingsSoundIOSaveUseCaseTests: XCTestCase {
    func testUpdatesSettings() {
        let factory = SystemAudioDeviceTestFactory()
        let soundIO = SimpleSoundIO(input: factory.someInput, output: factory.firstOutput, ringtoneOutput: factory.someOutput)
        let settings = SettingsFake()
        let sut = SettingsSoundIOSaveUseCase(soundIO: soundIO, settings: settings)

        sut.execute()

        XCTAssertEqual(settings[SettingsKeys.soundInput], soundIO.input.name)
        XCTAssertEqual(settings[SettingsKeys.soundOutput], soundIO.output.name)
        XCTAssertEqual(settings[SettingsKeys.ringtoneOutput], soundIO.ringtoneOutput.name)
    }

    func testDoesNotUpadteSettingsWithNilValues() {
        let settings = SettingsFake()
        let anyValue = "any-value"
        settings[SettingsKeys.soundInput] = anyValue
        settings[SettingsKeys.soundOutput] = anyValue
        settings[SettingsKeys.ringtoneOutput] = anyValue
        let sut = SettingsSoundIOSaveUseCase(
            soundIO: SimpleSoundIO(
                input: NullSystemAudioDevice(), output: NullSystemAudioDevice(), ringtoneOutput: NullSystemAudioDevice()
            ),
            settings: settings
        )

        sut.execute()

        XCTAssertEqual(settings[SettingsKeys.soundInput], anyValue)
        XCTAssertEqual(settings[SettingsKeys.soundOutput], anyValue)
        XCTAssertEqual(settings[SettingsKeys.ringtoneOutput], anyValue)
    }
}

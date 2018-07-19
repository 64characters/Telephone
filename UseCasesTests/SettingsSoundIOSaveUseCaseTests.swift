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

import Domain
import DomainTestDoubles
@testable import UseCases
import UseCasesTestDoubles
import XCTest

final class SettingsSoundIOSaveUseCaseTests: XCTestCase {
    func testUpdatesSettingsWithDeviceNames() {
        let factory = SystemAudioDeviceTestFactory()
        let inputName = factory.someInput.name
        let outputName = factory.firstOutput.name
        let ringtoneOutputName = factory.someOutput.name
        let settings = SettingsFake()
        let sut = SettingsSoundIOSaveUseCase(
            inputName: inputName, outputName: outputName, ringtoneOutputName: ringtoneOutputName, settings: settings
        )

        sut.execute()

        XCTAssertEqual(settings[SettingsKeys.soundInput], inputName)
        XCTAssertEqual(settings[SettingsKeys.soundOutput], outputName)
        XCTAssertEqual(settings[SettingsKeys.ringtoneOutput], ringtoneOutputName)
    }

    func testDoesNotUpadteSettingsWithEmptyDeviceNames() {
        let settings = SettingsFake()
        let anyValue = "any-value"
        settings[SettingsKeys.soundInput] = anyValue
        settings[SettingsKeys.soundOutput] = anyValue
        settings[SettingsKeys.ringtoneOutput] = anyValue
        let sut = SettingsSoundIOSaveUseCase(inputName: "", outputName: "", ringtoneOutputName: "", settings: settings)

        sut.execute()

        XCTAssertEqual(settings[SettingsKeys.soundInput], anyValue)
        XCTAssertEqual(settings[SettingsKeys.soundOutput], anyValue)
        XCTAssertEqual(settings[SettingsKeys.ringtoneOutput], anyValue)
    }
}

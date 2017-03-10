//
//  SettingsSoundIOSaveUseCaseTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

@testable import UseCases
import UseCasesTestDoubles
import XCTest

final class SettingsSoundIOSaveUseCaseTests: XCTestCase {
    func testUpdatesSettings() {
        let soundIO = PresentationSoundIO(input: "input", output: "output1", ringtoneOutput: "output2")
        let settings = SettingsFake()
        let sut = SettingsSoundIOSaveUseCase(soundIO: soundIO, settings: settings)

        sut.execute()

        XCTAssertEqual(settings[SettingsKeys.soundInput], soundIO.input)
        XCTAssertEqual(settings[SettingsKeys.soundOutput], soundIO.output)
        XCTAssertEqual(settings[SettingsKeys.ringtoneOutput], soundIO.ringtoneOutput)
    }

    func testDoesNotUpadteSettingsWithEmptyValues() {
        let settings = SettingsFake()
        let anyValue = "any-value"
        settings[SettingsKeys.soundInput] = anyValue
        settings[SettingsKeys.soundOutput] = anyValue
        settings[SettingsKeys.ringtoneOutput] = anyValue
        let sut = SettingsSoundIOSaveUseCase(
            soundIO: PresentationSoundIO(input: "", output: "", ringtoneOutput: ""), settings: settings
        )

        sut.execute()

        XCTAssertEqual(settings[SettingsKeys.soundInput], anyValue)
        XCTAssertEqual(settings[SettingsKeys.soundOutput], anyValue)
        XCTAssertEqual(settings[SettingsKeys.ringtoneOutput], anyValue)
    }
}

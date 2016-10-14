//
//  SettingsSoundIOSaveUseCaseTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

final class SettingsSoundIOSaveUseCaseTests: XCTestCase {
    func testUpdatesSettings() {
        let soundIO = PresentationSoundIO(input: "input", output: "output1", ringtoneOutput: "output2")
        let settings = SettingsFake()
        let sut = SettingsSoundIOSaveUseCase(soundIO: soundIO, settings: settings)

        sut.execute()

        XCTAssertEqual(settings[kSoundInput], soundIO.input)
        XCTAssertEqual(settings[kSoundOutput], soundIO.output)
        XCTAssertEqual(settings[kRingtoneOutput], soundIO.ringtoneOutput)
    }

    func testDoesNotUpadteSettingsWithEmptyValues() {
        let settings = SettingsFake()
        let anyValue = "any-value"
        settings[kSoundInput] = anyValue
        settings[kSoundOutput] = anyValue
        settings[kRingtoneOutput] = anyValue
        let sut = SettingsSoundIOSaveUseCase(
            soundIO: PresentationSoundIO(input: "", output: "", ringtoneOutput: ""), settings: settings
        )

        sut.execute()

        XCTAssertEqual(settings[kSoundInput], anyValue)
        XCTAssertEqual(settings[kSoundOutput], anyValue)
        XCTAssertEqual(settings[kRingtoneOutput], anyValue)
    }
}

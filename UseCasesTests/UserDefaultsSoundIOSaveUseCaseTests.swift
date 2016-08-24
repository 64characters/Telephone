//
//  UserDefaultsSoundIOSaveUseCaseTests.swift
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

final class UserDefaultsSoundIOSaveUseCaseTests: XCTestCase {
    func testUpdatesUserDefaults() {
        let soundIO = PresentationSoundIO(input: "input", output: "output1", ringtoneOutput: "output2")
        let defaults = UserDefaultsFake()
        let sut = UserDefaultsSoundIOSaveUseCase(soundIO: soundIO, defaults: defaults)

        sut.execute()

        XCTAssertEqual(defaults[kSoundInput], soundIO.input)
        XCTAssertEqual(defaults[kSoundOutput], soundIO.output)
        XCTAssertEqual(defaults[kRingtoneOutput], soundIO.ringtoneOutput)
    }

    func testDoesNotUpadteUserDefaultsWithEmptyValues() {
        let defaults = UserDefaultsFake()
        let anyValue = "any-value"
        defaults[kSoundInput] = anyValue
        defaults[kSoundOutput] = anyValue
        defaults[kRingtoneOutput] = anyValue
        let sut = UserDefaultsSoundIOSaveUseCase(
            soundIO: PresentationSoundIO(input: "", output: "", ringtoneOutput: ""), defaults: defaults
        )

        sut.execute()

        XCTAssertEqual(defaults[kSoundInput], anyValue)
        XCTAssertEqual(defaults[kSoundOutput], anyValue)
        XCTAssertEqual(defaults[kRingtoneOutput], anyValue)
    }
}

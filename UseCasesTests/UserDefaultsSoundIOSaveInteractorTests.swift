//
//  UserDefaultsSoundIOSaveInteractorTests.swift
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

class UserDefaultsSoundIOSaveInteractorTests: XCTestCase {
    func testUpdatesUserDefaults() {
        let soundIO = PresentationSoundIO(input: "input", output: "output1", ringtoneOutput: "output2")
        let userDefaults = UserDefaultsFake()
        let sut = UserDefaultsSoundIOSaveInteractor(soundIO: soundIO, userDefaults: userDefaults)

        sut.execute()

        XCTAssertEqual(userDefaults[kSoundInput], soundIO.input)
        XCTAssertEqual(userDefaults[kSoundOutput], soundIO.output)
        XCTAssertEqual(userDefaults[kRingtoneOutput], soundIO.ringtoneOutput)
    }

    func testDoesNotUpadteUserDefaultsWithEmptyValues() {
        let userDefaults = UserDefaultsFake()
        let anyValue = "any-value"
        userDefaults[kSoundInput] = anyValue
        userDefaults[kSoundOutput] = anyValue
        userDefaults[kRingtoneOutput] = anyValue
        let sut = UserDefaultsSoundIOSaveInteractor(
            soundIO: PresentationSoundIO(input: "", output: "", ringtoneOutput: ""),
            userDefaults: userDefaults)

        sut.execute()

        XCTAssertEqual(userDefaults[kSoundInput], anyValue)
        XCTAssertEqual(userDefaults[kSoundOutput], anyValue)
        XCTAssertEqual(userDefaults[kRingtoneOutput], anyValue)
    }
}

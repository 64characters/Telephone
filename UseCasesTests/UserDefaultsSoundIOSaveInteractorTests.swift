//
//  UserDefaultsSoundIOSaveInteractorTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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
    func testUsesExpectedUserDefaultsKeys() {
        let soundIO = SoundIO(soundInput: "input", soundOutput: "output1", ringtoneOutput: "output2")
        let userDefaults = UserDefaultsFake()
        let sut = UserDefaultsSoundIOSaveInteractor(soundIO: soundIO, userDefaults: userDefaults)

        sut.execute()

        XCTAssertEqual(userDefaults[kSoundInput], soundIO.soundInput)
        XCTAssertEqual(userDefaults[kSoundOutput], soundIO.soundOutput)
        XCTAssertEqual(userDefaults[kRingtoneOutput], soundIO.ringtoneOutput)
    }
}

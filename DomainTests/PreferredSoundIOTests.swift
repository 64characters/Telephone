//
//  PreferredSoundIOTests.swift
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
import XCTest

final class PreferredSoundIOTests: XCTestCase {
    func testPrefersFirstBuiltInDevices() {
        let factory = SystemAudioDeviceTestFactory()

        let sut = PreferredSoundIO(devices: factory.all)

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testFallsBackToFirstNonBuiltInDevices() {
        let factory = SystemAudioDeviceTestFactory()

        let sut = PreferredSoundIO(devices: [factory.firstInput, factory.firstOutput])

        XCTAssertTrue(sut.input == factory.firstInput)
        XCTAssertTrue(sut.output == factory.firstOutput)
        XCTAssertTrue(sut.ringtoneOutput == factory.firstOutput)
    }
}

//
//  FirstSystemSoundIOTests.swift
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

@testable import Domain
import DomainTestDoubles
import XCTest

class FirstSystemSoundIOTests: XCTestCase {
    private var deviceFactory: SystemAudioDeviceTestFactory!

    override func setUp() {
        super.setUp()
        deviceFactory = SystemAudioDeviceTestFactory()
    }

    func testInputIsFirstInputDevice() {
        let devices = [deviceFactory.someOutputDevice, deviceFactory.inputOnlyDevice, deviceFactory.firstBuiltInInput]

        let sut = try! FirstSystemSoundIO(devices: devices)

        XCTAssertEqual(sut.input, deviceFactory.inputOnlyDevice)
    }

    func testOutputIsFirstOutputDevice() {
        let devices = [deviceFactory.someInputDevice, deviceFactory.outputOnlyDevice, deviceFactory.firstBuiltInOutput]

        let sut = try! FirstSystemSoundIO(devices: devices)

        XCTAssertEqual(sut.output, deviceFactory.outputOnlyDevice)
    }
}

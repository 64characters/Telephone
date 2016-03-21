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
    private var factory: SystemAudioDeviceTestFactory!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
    }

    func testInputIsFirstInputDevice() {
        let devices = [factory.someOutputDevice, factory.inputOnlyDevice, factory.firstBuiltInInput]

        let sut = try! FirstSystemSoundIO(devices: devices)

        XCTAssertEqual(sut.input, factory.inputOnlyDevice)
    }

    func testOutputIsFirstOutputDevice() {
        let devices = [factory.someInputDevice, factory.outputOnlyDevice, factory.firstBuiltInOutput]

        let sut = try! FirstSystemSoundIO(devices: devices)

        XCTAssertEqual(sut.output, factory.outputOnlyDevice)
    }
}

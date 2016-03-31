//
//  FirstSystemAudioDeviceTests.swift
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

class FirstSystemAudioDeviceTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
    }

    func testCreatedWithFirstInputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.hasInputs })

        XCTAssertTrue(sut.device == factory.firstInput)
    }

    func testCreatedWithFirstOutputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.hasOutputs })

        XCTAssertTrue(sut.device == factory.firstOutput)
    }

    func testCreatedWithFirstBuiltInInputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.builtInInput })

        XCTAssertTrue(sut.device == factory.firstBuiltInInput)
    }

    func testCreatedWithFirstBuiltInOutputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.builtInOutput })

        XCTAssertTrue(sut.device == factory.firstBuiltInOutput)
    }

    func testIsNilWhenDeviceNotFound() {
        let sut = FirstSystemAudioDevice(
            devices: [factory.someOutput, factory.firstBuiltInOutput],
            predicate: { $0.hasInputs }
        )

        XCTAssertTrue(sut.device.isNil)
    }
}

//
//  FirstSystemAudioDeviceTests.swift
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

@testable import Domain
import DomainTestDoubles
import XCTest

final class FirstSystemAudioDeviceTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
    }

    func testCreatedWithFirstInputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.hasInputs })

        XCTAssertTrue(sut == factory.firstInput)
    }

    func testCreatedWithFirstOutputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.hasOutputs })

        XCTAssertTrue(sut == factory.firstOutput)
    }

    func testCreatedWithFirstBuiltInInputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.isBuiltInInput })

        XCTAssertTrue(sut == factory.firstBuiltInInput)
    }

    func testCreatedWithFirstBuiltInOutputDevice() {
        let sut = FirstSystemAudioDevice(devices: factory.all, predicate: { $0.isBuiltInOutput })

        XCTAssertTrue(sut == factory.firstBuiltInOutput)
    }

    func testIsNilWhenDeviceNotFound() {
        let sut = FirstSystemAudioDevice(
            devices: [factory.someOutput, factory.firstBuiltInOutput],
            predicate: { $0.hasInputs }
        )

        XCTAssertTrue(sut.isNil)
    }
}

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
        let sut = try! FirstSystemAudioDevice(devices: factory.all, predicate: { $0.inputDevice })

        XCTAssertEqual(sut.device, factory.firstInput)
    }

    func testCreatedWithFirstOutputDevice() {
        let sut = try! FirstSystemAudioDevice(devices: factory.all, predicate: { $0.outputDevice })

        XCTAssertEqual(sut.device, factory.firstOutput)
    }

    func testCreatedWithFirstBuiltInInputDevice() {
        let sut = try! FirstSystemAudioDevice(devices: factory.all, predicate: { $0.builtInInputDevice })

        XCTAssertEqual(sut.device, factory.firstBuiltInInput)
    }

    func testCreatedWithFirstBuiltInOutputDevice() {
        let sut = try! FirstSystemAudioDevice(devices: factory.all, predicate: { $0.builtInOutputDevice })

        XCTAssertEqual(sut.device, factory.firstBuiltInOutput)
    }

    func testThrowsSystemAudioDeviceNotFoundErrorIfNotFound() {
        var didThrow = false
        let devices = [factory.someOutput, factory.firstBuiltInOutput]

        do {
            _ = try FirstSystemAudioDevice(devices: devices, predicate: {$0.inputDevice })
        } catch Error.SystemAudioDeviceNotFoundError {
            didThrow = true
        } catch {}

        XCTAssertTrue(didThrow)
    }
}

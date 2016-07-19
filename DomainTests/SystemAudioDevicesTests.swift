//
//  SystemAudioDevicesTests.swift
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

@testable import Domain
import DomainTestDoubles
import XCTest

final class SystemAudioDevicesTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!
    private var sut: SystemAudioDevices!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        sut = SystemAudioDevices(devices: factory.all)
    }

    func testCanGetInputDeviceByName() {
        let inputDevice = factory.someInput

        XCTAssertTrue(sut.inputDeviceNamed(inputDevice.name) == inputDevice)
    }

    func testCanGetOutputDeviceByName() {
        let outputDevice = factory.someOutput

        XCTAssertTrue(sut.outputDeviceNamed(outputDevice.name) == outputDevice)
    }

    func testCanGetInputDevices() {
        XCTAssertTrue(sut.input == factory.allInput)
    }

    func testCanGetOutputDevices() {
        XCTAssertTrue(sut.output == factory.allOutput)
    }

    func testReturnsNullObjectsWhenNoDevicesFound() {
        XCTAssertTrue(sut.inputDeviceNamed("nonexistent").isNil)
        XCTAssertTrue(sut.outputDeviceNamed("nonexistent").isNil)
    }
}

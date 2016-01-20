//
//  SystemAudioDevicesTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov
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

class SystemAudioDevicesTests: XCTestCase {
    private var deviceFactory: SystemAudioDeviceTestFactory!
    private var sut: SystemAudioDevices!

    override func setUp() {
        super.setUp()
        deviceFactory = SystemAudioDeviceTestFactory()
        sut = SystemAudioDevices(devices: deviceFactory.allDevices)
    }

    func testCanGetInputDeviceByName() {
        let inputDevice = deviceFactory.someInputDevice

        XCTAssertEqual(sut.inputDeviceNamed(inputDevice.name), inputDevice)
    }

    func testCanGetOutputDeviceByName() {
        let outputDevice = deviceFactory.someOutputDevice

        XCTAssertEqual(sut.outputDeviceNamed(outputDevice.name), outputDevice)
    }

    func testCanGetInputDevices() {
        XCTAssertEqual(sut.inputDevices, deviceFactory.inputDevices)
    }

    func testCanGetOutputDevices() {
        XCTAssertEqual(sut.outputDevices, deviceFactory.outputDevices)
    }
}

//
//  SystemToUserAgentAudioDeviceMapTests.swift
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

class SystemToUserAgentAudioDeviceMapTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
    }

    func testMapsSystemToUserAgentDeviceByNameAndIOPort() {
        let systemDevices = factory.all
        let userAgentDevices: [UserAgentAudioDevice] = [
            SimpleUserAgentAudioDevice(device: factory.someInput),
            SimpleUserAgentAudioDevice(device: factory.someOutput)
        ]

        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: systemDevices, userAgentDevices: userAgentDevices)

        XCTAssertTrue(sut.userAgentDeviceForSystemDevice(factory.someInput) == userAgentDevices[0])
        XCTAssertTrue(sut.userAgentDeviceForSystemDevice(factory.someOutput) == userAgentDevices[1])
    }

    func testMapsSystemToUserAgentDeviceByNameAndIOPortWhenTwoDevicesHaveTheSameName() {
        let systemDevices = [factory.someInput, factory.outputWithNameLikeSomeInput]
        let userAgentDevices: [UserAgentAudioDevice] = [
            SimpleUserAgentAudioDevice(device: systemDevices[1]),
            SimpleUserAgentAudioDevice(device: systemDevices[0])
        ]

        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: systemDevices, userAgentDevices: userAgentDevices)

        XCTAssertTrue(sut.userAgentDeviceForSystemDevice(sut.systemDevices[0]) == sut.userAgentDevices[1])
        XCTAssertTrue(sut.userAgentDeviceForSystemDevice(sut.systemDevices[1]) == sut.userAgentDevices[0])
    }

    func testReturnsNullObjectWhenNoMatchingUserAgentDeviceFound() {
        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: factory.all, userAgentDevices: [])

        let result = sut.userAgentDeviceForSystemDevice(factory.someInput)

        XCTAssertTrue(result.isNil)
    }
}

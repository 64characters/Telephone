//
//  SystemToUserAgentAudioDeviceMapTests.swift
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

class SystemToUserAgentAudioDeviceMapTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
    }

    func testMapsSystemToUserAgentDeviceByNameAndIOPort() {
        let systemDevices = factory.all
        let userAgentDevices = [
            UserAgentAudioDevice(device: factory.someInput),
            UserAgentAudioDevice(device: factory.someOutput)
        ]

        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: systemDevices, userAgentDevices: userAgentDevices)

        XCTAssertEqual(try! sut.userAgentDeviceForSystemDevice(factory.someInput), userAgentDevices[0])
        XCTAssertEqual(try! sut.userAgentDeviceForSystemDevice(factory.someOutput), userAgentDevices[1])
    }

    func testMapsSystemToUserAgentDeviceByNameAndIOPortWhenTwoDevicesHaveTheSameName() {
        let systemDevices = [factory.someInput, factory.outputWithNameLikeSomeInput]
        let userAgentDevices = [
            UserAgentAudioDevice(device: systemDevices[1]),
            UserAgentAudioDevice(device: systemDevices[0])
        ]

        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: systemDevices, userAgentDevices: userAgentDevices)

        XCTAssertEqual(try! sut.userAgentDeviceForSystemDevice(sut.systemDevices[0]), sut.userAgentDevices[1])
        XCTAssertEqual(try! sut.userAgentDeviceForSystemDevice(sut.systemDevices[1]), sut.userAgentDevices[0])
    }

    func testThrowsWhenNoMatchingUserAgentDeviceFound() {
        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: factory.all, userAgentDevices: [])

        var didThrow = false
        do {
            try sut.userAgentDeviceForSystemDevice(factory.someInput)
        } catch {
            didThrow = true
        }

        XCTAssertTrue(didThrow)
    }
}

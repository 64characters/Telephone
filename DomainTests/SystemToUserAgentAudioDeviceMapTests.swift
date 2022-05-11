//
//  SystemToUserAgentAudioDeviceMapTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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

final class SystemToUserAgentAudioDeviceMapTests: XCTestCase {
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

        XCTAssertTrue(sut.userAgentDevice(for: factory.someInput) == userAgentDevices[0])
        XCTAssertTrue(sut.userAgentDevice(for: factory.someOutput) == userAgentDevices[1])
    }

    func testMapsSystemToUserAgentDeviceByNameAndIOPortWhenTwoDevicesHaveTheSameName() {
        let systemDevices = [factory.someInput, factory.outputWithNameLikeSomeInput]
        let userAgentDevices: [UserAgentAudioDevice] = [
            SimpleUserAgentAudioDevice(device: systemDevices[1]),
            SimpleUserAgentAudioDevice(device: systemDevices[0])
        ]

        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: systemDevices, userAgentDevices: userAgentDevices)

        XCTAssertTrue(sut.userAgentDevice(for: systemDevices[0]) == userAgentDevices[1])
        XCTAssertTrue(sut.userAgentDevice(for: systemDevices[1]) == userAgentDevices[0])
    }

    func testReturnsNullObjectWhenNoMatchingUserAgentDeviceFound() {
        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: factory.all, userAgentDevices: [])

        let result = sut.userAgentDevice(for: factory.someInput)

        XCTAssertTrue(result.isNil)
    }
}

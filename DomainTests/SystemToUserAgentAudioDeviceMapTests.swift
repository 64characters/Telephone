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
    private var systemDevices: [SystemAudioDevice]!

    override func setUp() {
        super.setUp()
        systemDevices = createSystemDevices()
    }

    func testMapsSystemToUserAgentDeviceByName() {
        let sut = createDeviceMap()

        XCTAssertEqual(try! sut.userAgentDeviceForSystemDevice(sut.systemDevices[0]), sut.userAgentDevices[1])
        XCTAssertEqual(try! sut.userAgentDeviceForSystemDevice(sut.systemDevices[1]), sut.userAgentDevices[0])
    }

    func testThrowsWhenNoMatchingUserAgentDeviceFound() {
        let sut = SystemToUserAgentAudioDeviceMap(systemDevices: systemDevices, userAgentDevices: [])

        var thrownError: ErrorType?
        do {
            try sut.userAgentDeviceForSystemDevice(sut.systemDevices.first!)
        } catch {
            thrownError = error
        }

        XCTAssertNotNil(thrownError)
    }

    private func createDeviceMap() -> SystemToUserAgentAudioDeviceMap {
        let userAgentDevices = createUserAgentDevices()
        return SystemToUserAgentAudioDeviceMap(systemDevices: systemDevices, userAgentDevices: userAgentDevices)
    }

    private func createSystemDevices() -> [SystemAudioDevice] {
        return Array(SystemAudioDeviceTestFactory().all[0..<2])
    }

    private func createUserAgentDevices() -> [UserAgentAudioDevice] {
        let device1 = UserAgentAudioDevice(identifier: 1, name: systemDevices[1].name)
        let device2 = UserAgentAudioDevice(identifier: 2, name: systemDevices[0].name)
        return [device1, device2]
    }
}

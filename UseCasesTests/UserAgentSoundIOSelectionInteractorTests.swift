//
//  UserAgentSoundIOSelectionInteractorTests.swift
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

import Domain
import DomainTestDoubles
import UseCases
import UseCasesTestDoubles
import XCTest

class UserAgentSoundIOSelectionInteractorTests: XCTestCase {
    private var systemDevices: SystemAudioDevices!
    private var repositoryStub: SystemAudioDeviceRepositoryStub!
    private var userAgentSpy: UserAgentSpy!
    private var userDefaultsDummy: UserDefaultsFake!
    private var sut: UserAgentSoundIOSelectionInteractor!

    override func setUp() {
        super.setUp()
        systemDevices = createSystemDevices()
        repositoryStub = SystemAudioDeviceRepositoryStub()
        repositoryStub.allDevicesResult = systemDevices.allDevices
        userAgentSpy = UserAgentSpy()
        userAgentSpy.audioDevicesResult = createUserAgentDevices()
        userDefaultsDummy = UserDefaultsFake()
        sut = createInteractor()
    }

    func testSelectsMappedAudioDevices() {
        try! sut.execute()

        let userAgentDevices: [UseCases.UserAgentAudioDevice] = userAgentSpy.audioDevicesResult
        XCTAssertEqual(userAgentSpy.selectedInputDeviceID, userAgentDevices[1].identifier)
        XCTAssertEqual(userAgentSpy.selectedOutputDeviceID, userAgentDevices[0].identifier)
    }

    private func createSystemDevices() -> SystemAudioDevices {
        let factory = SystemAudioDeviceTestFactory()
        return SystemAudioDevices(devices: [factory.firstBuiltInInput, factory.firstBuiltInOutput])
    }

    private func createUserAgentDevices() -> [UseCases.UserAgentAudioDevice] {
        let device1 = UseCases.UserAgentAudioDevice(identifier: 1, name: systemDevices.allDevices[1].name)
        let device2 = UseCases.UserAgentAudioDevice(identifier: 2, name: systemDevices.allDevices[0].name)
        return [device1, device2]
    }

    private func createInteractor() -> UserAgentSoundIOSelectionInteractor {
        return UserAgentSoundIOSelectionInteractor(systemAudioDeviceRepository: repositoryStub, userAgent: userAgentSpy, userDefaults: userDefaultsDummy)
    }
}

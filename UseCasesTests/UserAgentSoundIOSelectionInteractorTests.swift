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
    private var devices: SystemAudioDevices!
    private var repository: SystemAudioDeviceRepositoryStub!
    private var userAgent: UserAgentSpy!
    private var userDefaults: UserDefaultsFake!
    private var sut: UserAgentSoundIOSelectionInteractor!

    override func setUp() {
        super.setUp()
        devices = createSystemDevices()
        repository = SystemAudioDeviceRepositoryStub()
        repository.allDevicesResult = devices.all
        userAgent = UserAgentSpy()
        userAgent.audioDevicesResult = createUserAgentDevices()
        userDefaults = UserDefaultsFake()
        sut = createInteractor()
    }

    func testSelectsMappedAudioDevices() {
        try! sut.execute()

        let devices: [UseCases.UserAgentAudioDevice] = userAgent.audioDevicesResult
        XCTAssertEqual(userAgent.invokedInputDeviceID, devices[1].identifier)
        XCTAssertEqual(userAgent.invokedOutputDeviceID, devices[0].identifier)
    }

    private func createSystemDevices() -> SystemAudioDevices {
        let factory = SystemAudioDeviceTestFactory()
        return SystemAudioDevices(devices: [factory.firstBuiltInInput, factory.firstBuiltInOutput])
    }

    private func createUserAgentDevices() -> [UseCases.UserAgentAudioDevice] {
        return [
            UseCases.UserAgentAudioDevice(identifier: 1, name: devices.all[1].name),
            UseCases.UserAgentAudioDevice(identifier: 2, name: devices.all[0].name)
        ]
    }

    private func createInteractor() -> UserAgentSoundIOSelectionInteractor {
        return UserAgentSoundIOSelectionInteractor(repository: repository, userAgent: userAgent, userDefaults: userDefaults)
    }
}

//
//  UserDefaultsRingtoneSoundConfigurationLoadInteractorTests.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
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

import DomainTestDoubles
import UseCases
import UseCasesTestDoubles
import XCTest

class UserDefaultsRingtoneSoundConfigurationLoadInteractorTests: XCTestCase {
    private var audioDeviceFactory: SystemAudioDeviceTestFactory!
    private var userDefaults: UserDefaultsFake!
    private var audioDeviceRepositoryStub: SystemAudioDeviceRepositoryStub!
    private var sut: SoundConfigurationLoadInteractor!

    override func setUp() {
        super.setUp()
        audioDeviceFactory = SystemAudioDeviceTestFactory()
        userDefaults = UserDefaultsFake()
        audioDeviceRepositoryStub = SystemAudioDeviceRepositoryStub()
        sut = UserDefaultsRingtoneSoundConfigurationLoadInteractor(
            userDefaults: userDefaults,
            systemAudioDeviceRepository: audioDeviceRepositoryStub
        )
    }

    func testReturnsRingtoneSoundConfigurationFromUserDefaults() {
        let outputDevice = audioDeviceFactory.someOutputDevice
        userDefaults[kRingtoneOutput] = outputDevice.name
        userDefaults[kRingingSound] = "sound-name"
        audioDeviceRepositoryStub.allDevicesResult = audioDeviceFactory.allDevices

        let result = try! sut.execute()

        XCTAssertEqual(result.name, "sound-name")
        XCTAssertEqual(result.deviceUID, outputDevice.uniqueIdentifier)
    }

    func testThrowsRingtoneSoundNameNotFoundErrorWhenSoundNameCanNotBeFoundInUserDefaults() {
        audioDeviceRepositoryStub.allDevicesResult = audioDeviceFactory.allDevices
        var result = false

        do {
            try sut.execute()
        } catch Error.RingtoneSoundNameNotFoundError {
            result = true
        } catch {}

        XCTAssertTrue(result)
    }
}

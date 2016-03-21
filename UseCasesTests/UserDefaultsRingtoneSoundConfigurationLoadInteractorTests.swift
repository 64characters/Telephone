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
    private var factory: SystemAudioDeviceTestFactory!
    private var userDefaults: UserDefaultsFake!
    private var repository: SystemAudioDeviceRepositoryStub!
    private var sut: SoundConfigurationLoadInteractor!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        userDefaults = UserDefaultsFake()
        repository = SystemAudioDeviceRepositoryStub()
        sut = UserDefaultsRingtoneSoundConfigurationLoadInteractor(
            userDefaults: userDefaults,
            repository: repository
        )
    }

    func testReturnsRingtoneSoundConfigurationFromUserDefaults() {
        let outputDevice = factory.someOutput
        userDefaults[kRingtoneOutput] = outputDevice.name
        userDefaults[kRingingSound] = "sound-name"
        repository.allDevicesResult = factory.all

        let result = try! sut.execute()

        XCTAssertEqual(result.name, "sound-name")
        XCTAssertEqual(result.deviceUID, outputDevice.uniqueIdentifier)
    }

    func testThrowsRingtoneSoundNameNotFoundErrorWhenSoundNameCanNotBeFoundInUserDefaults() {
        repository.allDevicesResult = factory.all
        var result = false

        do {
            try sut.execute()
        } catch Error.RingtoneSoundNameNotFoundError {
            result = true
        } catch {}

        XCTAssertTrue(result)
    }
}

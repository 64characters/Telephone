//
//  SettingsRingtoneSoundConfigurationLoadUseCaseTests.swift
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

import DomainTestDoubles
@testable import UseCases
import UseCasesTestDoubles
import XCTest

final class SettingsRingtoneSoundConfigurationLoadUseCaseTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!
    private var settings: SettingsFake!
    private var repository: SystemAudioDeviceRepositoryStub!
    private var sut: SoundConfigurationLoadUseCase!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        settings = SettingsFake()
        repository = SystemAudioDeviceRepositoryStub()
        sut = SettingsRingtoneSoundConfigurationLoadUseCase(settings: settings, repository: repository)
    }

    func testReturnsRingtoneSoundConfigurationFromSettings() {
        let outputDevice = factory.someOutput
        settings[SettingsKeys.ringtoneOutput] = outputDevice.name
        settings[SettingsKeys.ringingSound] = "sound-name"
        repository.allDevicesResult = factory.all

        let result = try! sut.execute()

        XCTAssertEqual(result.name, "sound-name")
        XCTAssertEqual(result.deviceUID, outputDevice.uniqueIdentifier)
    }

    func testThrowsRingtoneSoundNameNotFoundErrorWhenSoundNameCanNotBeFoundInSettings() {
        repository.allDevicesResult = factory.all
        var result = false

        do {
            try _ = sut.execute()
        } catch UseCasesError.ringtoneSoundNameNotFoundError {
            result = true
        } catch {}

        XCTAssertTrue(result)
    }
}

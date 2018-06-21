//
//  SettingsRingtoneSoundConfigurationLoadUseCaseTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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
    func testResultNameIsRingingSoundFromSettingsAndDeviceUIDIsUniqueIdentifierOfRingtoneOutputFromPreferredSoundIO() throws {
        let settings = SettingsFake()
        settings[SettingsKeys.ringtoneOutput] = SystemAudioDeviceTestFactory().someOutput.name
        settings[SettingsKeys.ringingSound] = "any-sound"
        let factory = SystemAudioDevicesTestFactory(factory: SystemAudioDeviceTestFactory())
        let sut = SettingsRingtoneSoundConfigurationLoadUseCase(settings: settings, factory: factory)
        let soundIO = PreferredSoundIO(devices: try factory.make(), settings: settings)

        let result = try sut.execute()

        XCTAssertEqual(result.name, "any-sound")
        XCTAssertEqual(result.deviceUID, soundIO.ringtoneOutput.uniqueIdentifier)
    }

    func testThrowsRingtoneSoundNameNotFoundErrorWhenSoundNameCanNotBeFoundInSettings() {
        let sut = SettingsRingtoneSoundConfigurationLoadUseCase(
            settings: SettingsFake(), factory: SystemAudioDevicesTestFactory(factory: SystemAudioDeviceTestFactory())
        )

        XCTAssertThrowsError(try sut.execute()) { (error) in
            XCTAssertEqual(error as? UseCasesError, .ringtoneSoundNameNotFoundError)
        }
    }
}

//
//  SettingsRingtoneSoundConfigurationLoadUseCaseTests.swift
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

import Domain
import DomainTestDoubles
import Testing
@testable import UseCases
import UseCasesTestDoubles

@MainActor
struct SettingsRingtoneSoundConfigurationLoadUseCaseTests {
    @Test func resultNameIsRingingSoundFromSettingsAndDeviceUIDIsUniqueIdentifierOfRingtoneOutputFromSoundIO() async throws {
        let sound = "any-sound"
        let output = SystemAudioDeviceTestFactory().someOutput
        let settings = SettingsFake()
        settings[SettingsKeys.ringingSound] = sound
        settings[SettingsKeys.ringtoneOutput] = output.name
        let sut = SettingsRingtoneSoundConfigurationLoadUseCase(
            settings: settings,
            factory: SoundIOFactoryStub(
                soundIO: SimpleSoundIO(
                    input: NullSystemAudioDevice(), output: NullSystemAudioDevice(), ringtoneOutput: output
                )
            )
        )

        let result = try sut.execute()

        #expect(result.name == sound)
        #expect(result.deviceUID == output.uniqueIdentifier)
    }

    @Test func throwsRingtoneSoundNameNotFoundErrorWhenSoundNameCanNotBeFoundInSettings() async {
        let sut = SettingsRingtoneSoundConfigurationLoadUseCase(
            settings: SettingsFake(), factory: SoundIOFactoryStub(soundIO: NullSoundIO())
        )

        #expect(throws: UseCasesError.ringtoneSoundNameNotFoundError) {
            try sut.execute()
        }
    }
}

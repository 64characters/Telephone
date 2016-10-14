//
//  SettingsRingtoneSoundConfigurationLoadUseCase.swift
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

import Domain

public final class SettingsRingtoneSoundConfigurationLoadUseCase {
    fileprivate let settings: KeyValueSettings
    fileprivate let repository: SystemAudioDeviceRepository

    public init(settings: KeyValueSettings, repository: SystemAudioDeviceRepository) {
        self.settings = settings
        self.repository = repository
    }
}

extension SettingsRingtoneSoundConfigurationLoadUseCase: SoundConfigurationLoadUseCase {
    public func execute() throws -> SoundConfiguration {
        return SoundConfiguration(name: try ringtoneSoundName(), deviceUID: try ringtoneAudioDeviceUID())
    }

    private func ringtoneSoundName() throws -> String {
        if let name = settings[kRingingSound] {
            return name
        } else {
            throw UseCasesError.ringtoneSoundNameNotFoundError
        }
    }

    private func ringtoneAudioDeviceUID() throws -> String {
        let soundIO = PreferredSoundIO(
            devices: SystemAudioDevices(devices: try repository.allDevices()), settings: settings
        )
        return soundIO.ringtoneOutput.uniqueIdentifier
    }
}

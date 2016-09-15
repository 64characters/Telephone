//
//  UserDefaultsRingtoneSoundConfigurationLoadUseCase.swift
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

public final class UserDefaultsRingtoneSoundConfigurationLoadUseCase {
    fileprivate let defaults: KeyValueUserDefaults
    fileprivate let repository: SystemAudioDeviceRepository

    public init(defaults: KeyValueUserDefaults, repository: SystemAudioDeviceRepository) {
        self.defaults = defaults
        self.repository = repository
    }
}

extension UserDefaultsRingtoneSoundConfigurationLoadUseCase: SoundConfigurationLoadUseCase {
    public func execute() throws -> SoundConfiguration {
        return SoundConfiguration(name: try ringtoneSoundName(), deviceUID: try ringtoneAudioDeviceUID())
    }

    fileprivate func ringtoneSoundName() throws -> String {
        if let name = defaults[kRingingSound] {
            return name
        } else {
            throw UseCasesError.ringtoneSoundNameNotFoundError
        }
    }

    fileprivate func ringtoneAudioDeviceUID() throws -> String {
        let soundIO = PreferredSoundIO(
            devices: SystemAudioDevices(devices: try repository.allDevices()), defaults: defaults
        )
        return soundIO.ringtoneOutput.uniqueIdentifier
    }
}

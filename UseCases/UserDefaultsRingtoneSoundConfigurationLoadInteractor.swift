//
//  UserDefaultsRingtoneSoundConfigurationLoadInteractor.swift
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

import Domain

public class UserDefaultsRingtoneSoundConfigurationLoadInteractor {
    public let userDefaults: UserDefaults
    public let repository: SystemAudioDeviceRepository

    public init(userDefaults: UserDefaults, repository: SystemAudioDeviceRepository) {
        self.userDefaults = userDefaults
        self.repository = repository
    }
}

extension UserDefaultsRingtoneSoundConfigurationLoadInteractor: SoundConfigurationLoadInteractor {
    public func execute() throws -> SoundConfiguration {
        return SoundConfiguration(name: try ringtoneSoundName(), deviceUID: try ringtoneAudioDeviceUID())
    }

    private func ringtoneSoundName() throws -> String {
        if let name = userDefaults[kRingingSound] {
            return name
        } else {
            throw Error.RingtoneSoundNameNotFoundError
        }
    }

    private func ringtoneAudioDeviceUID() throws -> String {
        let soundIO = SavedSystemSoundIO(
            devices: SystemAudioDevices(devices: try repository.allDevices()),
            userDefaults: userDefaults
        )
        return soundIO.ringtoneOutput.uniqueIdentifier
    }
}
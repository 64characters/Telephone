//
//  InteractorFactoryImpl.swift
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

import UseCases

class InteractorFactoryImpl {
    let systemAudioDeviceRepository: SystemAudioDeviceRepository
    let userDefaults: UserDefaults

    init(systemAudioDeviceRepository: SystemAudioDeviceRepository, userDefaults: UserDefaults) {
        self.systemAudioDeviceRepository = systemAudioDeviceRepository
        self.userDefaults = userDefaults
    }
}

extension InteractorFactoryImpl: InteractorFactory {
    func createUserAgentSoundIOSelectionInteractor(userAgent userAgent: UserAgent) -> ThrowingInteractor {
        return UserAgentSoundIOSelectionInteractor(
            systemAudioDeviceRepository: systemAudioDeviceRepository,
            userAgent: userAgent,
            userDefaults: userDefaults
        )
    }

    func createUserDefaultsSoundIOLoadInteractor(output output: UserDefaultsSoundIOLoadInteractorOutput) -> ThrowingInteractor {
        return UserDefaultsSoundIOLoadInteractor(
            systemAudioDeviceRepository: systemAudioDeviceRepository,
            userDefaults: userDefaults,
            output: output
        )
    }

    func createUserDefaultsSoundIOSaveInteractor(soundIO soundIO: SoundIO) -> Interactor {
        return UserDefaultsSoundIOSaveInteractor(soundIO: soundIO, userDefaults: userDefaults)
    }

    func createUserDefaultsRingtoneSoundNameSaveInteractor(name name: String) -> Interactor {
        return UserDefaultsRingtoneSoundNameSaveInteractor(soundName: name, userDefaults: userDefaults)
    }
}

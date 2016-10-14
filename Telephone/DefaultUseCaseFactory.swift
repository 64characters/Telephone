//
//  DefaultUseCaseFactory.swift
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

import UseCases

final class DefaultUseCaseFactory {
    fileprivate let repository: SystemAudioDeviceRepository
    fileprivate let settings: KeyValueSettings

    init(repository: SystemAudioDeviceRepository, settings: KeyValueSettings) {
        self.repository = repository
        self.settings = settings
    }
}

extension DefaultUseCaseFactory: UseCaseFactory {
    func makeSettingsSoundIOLoadUseCase(output: SettingsSoundIOLoadUseCaseOutput) -> ThrowingUseCase {
        return SettingsSoundIOLoadUseCase(repository: repository, settings: settings, output: output)
    }

    func makeSettingsSoundIOSaveUseCase(soundIO: PresentationSoundIO) -> UseCase {
        return SettingsSoundIOSaveUseCase(soundIO: soundIO, settings: settings)
    }

    func makeSettingsRingtoneSoundNameSaveUseCase(name: String) -> UseCase {
        return SettingsRingtoneSoundNameSaveUseCase(name: name, settings: settings)
    }
}

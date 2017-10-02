//
//  SettingsSoundIOLoadUseCase.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

public protocol SettingsSoundIOLoadUseCaseOutput: class {
    func update(devices: AudioDevices, soundIO: PresentationSoundIO)
}

public final class SettingsSoundIOLoadUseCase {
    private let repository: SystemAudioDeviceRepository
    private let settings: KeyValueSettings
    private let output: SettingsSoundIOLoadUseCaseOutput

    public init(repository: SystemAudioDeviceRepository, settings: KeyValueSettings, output: SettingsSoundIOLoadUseCaseOutput) {
        self.repository = repository
        self.settings = settings
        self.output = output
    }
}

extension SettingsSoundIOLoadUseCase: ThrowingUseCase {
    public func execute() throws {
        let devices = SystemAudioDevices(devices: try repository.allDevices())
        output.update(
            devices: AudioDevices(devices: devices),
            soundIO: PresentationSoundIO(soundIO: PreferredSoundIO(devices: devices, settings: settings))
        )
    }
}

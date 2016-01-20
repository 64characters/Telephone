//
//  UserDefaultsSoundIOLoadInteractor.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

public protocol UserDefaultsSoundIOLoadInteractorOutput: class {
    func update(audioDevices: AudioDevices, soundIO: SoundIO)
}

public class UserDefaultsSoundIOLoadInteractor {
    public let systemAudioDeviceRepository: SystemAudioDeviceRepository
    public let userDefaults: UserDefaults
    public let output: UserDefaultsSoundIOLoadInteractorOutput

    public init(systemAudioDeviceRepository: SystemAudioDeviceRepository, userDefaults: UserDefaults, output: UserDefaultsSoundIOLoadInteractorOutput) {
        self.systemAudioDeviceRepository = systemAudioDeviceRepository
        self.userDefaults = userDefaults
        self.output = output
    }
}

extension UserDefaultsSoundIOLoadInteractor: ThrowingInteractor {
    public func execute() throws {
        let systemAudioDevices = SystemAudioDevices(devices: try systemAudioDeviceRepository.allDevices())
        let selectedSystemSoundIO = try SelectedSystemSoundIO(systemAudioDevices: systemAudioDevices, userDefaults: userDefaults)
        output.update(
            AudioDevices(systemAudioDevices: systemAudioDevices),
            soundIO: SoundIO(selectedSystemSoundIO: selectedSystemSoundIO)
        )
    }
}

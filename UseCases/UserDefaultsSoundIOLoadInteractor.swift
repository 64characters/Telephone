//
//  UserDefaultsSoundIOLoadInteractor.swift
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

import Domain

public protocol UserDefaultsSoundIOLoadInteractorOutput: class {
    func update(devices devices: AudioDevices, soundIO: SoundIO)
}

public class UserDefaultsSoundIOLoadInteractor {
    public let repository: SystemAudioDeviceRepository
    public let userDefaults: UserDefaults
    public let output: UserDefaultsSoundIOLoadInteractorOutput

    public init(repository: SystemAudioDeviceRepository, userDefaults: UserDefaults, output: UserDefaultsSoundIOLoadInteractorOutput) {
        self.repository = repository
        self.userDefaults = userDefaults
        self.output = output
    }
}

extension UserDefaultsSoundIOLoadInteractor: ThrowingInteractor {
    public func execute() throws {
        let devices = SystemAudioDevices(devices: try repository.allDevices())
        let soundIO = try SelectedSystemSoundIO(devices: devices, userDefaults: userDefaults)
        output.update(
            devices: AudioDevices(devices: devices),
            soundIO: SoundIO(soundIO: soundIO)
        )
    }
}

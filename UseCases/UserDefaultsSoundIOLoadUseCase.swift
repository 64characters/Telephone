//
//  UserDefaultsSoundIOLoadUseCase.swift
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

public protocol UserDefaultsSoundIOLoadUseCaseOutput: class {
    func update(devices devices: AudioDevices, soundIO: PresentationSoundIO)
}

public final class UserDefaultsSoundIOLoadUseCase {
    private let repository: SystemAudioDeviceRepository
    private let userDefaults: StringUserDefaults
    private let output: UserDefaultsSoundIOLoadUseCaseOutput

    public init(repository: SystemAudioDeviceRepository, userDefaults: StringUserDefaults, output: UserDefaultsSoundIOLoadUseCaseOutput) {
        self.repository = repository
        self.userDefaults = userDefaults
        self.output = output
    }
}

extension UserDefaultsSoundIOLoadUseCase: ThrowingUseCase {
    public func execute() throws {
        let devices = SystemAudioDevices(devices: try repository.allDevices())
        output.update(
            devices: AudioDevices(devices: devices),
            soundIO: PresentationSoundIO(
                soundIO: PreferredSoundIO(devices: devices, userDefaults: userDefaults)
            )
        )
    }
}

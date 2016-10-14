//
//  UseCaseFactorySpy.swift
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

public final class UseCaseFactorySpy {
    public fileprivate(set) var invokedSoundIO = PresentationSoundIO(input: "", output: "", ringtoneOutput: "")
    public fileprivate(set) var invokedRingtoneSoundName = ""

    fileprivate var soundIOLoad: ThrowingUseCase!
    fileprivate var soundIOSave: UseCase!
    fileprivate var ringtoneSoundNameSave: UseCase!

    public init() {}

    public func stub(withSettingsSoundIOLoad useCase: ThrowingUseCase) {
        soundIOLoad = useCase
    }

    public func stub(withSettingsSoundIOSave useCase: UseCase) {
        soundIOSave = useCase
    }

    public func stub(withSettingsRingtoneSoundNameSave useCase: UseCase) {
        ringtoneSoundNameSave = useCase
    }
}

extension UseCaseFactorySpy: UseCaseFactory {
    public func makeSettingsSoundIOLoadUseCase(output: SettingsSoundIOLoadUseCaseOutput) -> ThrowingUseCase {
        return soundIOLoad
    }

    public func makeSettingsSoundIOSaveUseCase(soundIO: PresentationSoundIO) -> UseCase {
        invokedSoundIO = soundIO
        return soundIOSave
    }

    public func makeSettingsRingtoneSoundNameSaveUseCase(name: String) -> UseCase {
        invokedRingtoneSoundName = name
        return ringtoneSoundNameSave
    }
}

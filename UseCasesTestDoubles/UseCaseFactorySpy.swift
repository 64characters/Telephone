//
//  UseCaseFactorySpy.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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
import UseCases

public final class UseCaseFactorySpy {
    public private(set) var invokedSoundIO: SystemDefaultingSoundIO?
    public private(set) var invokedRingtoneSoundName: String?

    private var soundIOLoad: ThrowingUseCase!
    private var soundIOSave: UseCase!
    private var ringtoneSoundNameSave: UseCase!

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

    public func makeSettingsSoundIOSaveUseCase(soundIO: SystemDefaultingSoundIO) -> UseCase {
        invokedSoundIO = soundIO
        return soundIOSave
    }

    public func makeSettingsRingtoneSoundNameSaveUseCase(name: String) -> UseCase {
        invokedRingtoneSoundName = name
        return ringtoneSoundNameSave
    }
}

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

public class UseCaseFactorySpy {
    public private(set) var invokedSoundIO = PresentationSoundIO(input: "", output: "", ringtoneOutput: "")
    public private(set) var invokedRingtoneSoundName = ""

    private var userDefaultsSoundIOLoad: ThrowingUseCase!
    private var userDefaultsSoundIOSave: UseCase!
    private var userDefaultsRingtoneSoundNameSave: UseCase!

    public init() {}

    public func stubWithUserDefaultsSoundIOLoad(useCase: ThrowingUseCase) {
        userDefaultsSoundIOLoad = useCase
    }

    public func stubWithUserDefaultsSoundIOSave(useCase: UseCase) {
        userDefaultsSoundIOSave = useCase
    }

    public func stubWithUserDefaultsRingtoneSoundNameSave(useCase: UseCase) {
        userDefaultsRingtoneSoundNameSave = useCase
    }
}

extension UseCaseFactorySpy: UseCaseFactory {
    public func createUserDefaultsSoundIOLoadUseCase(output output: UserDefaultsSoundIOLoadUseCaseOutput) -> ThrowingUseCase {
        return userDefaultsSoundIOLoad
    }

    public func createUserDefaultsSoundIOSaveUseCase(soundIO soundIO: PresentationSoundIO) -> UseCase {
        invokedSoundIO = soundIO
        return userDefaultsSoundIOSave
    }

    public func createUserDefaultsRingtoneSoundNameSaveUseCase(name name: String) -> UseCase {
        invokedRingtoneSoundName = name
        return userDefaultsRingtoneSoundNameSave
    }
}

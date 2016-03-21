//
//  InteractorFactorySpy.swift
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

public class InteractorFactorySpy {
    public private(set) var userAgentSoundIOSelection: ThrowingInteractor!
    public private(set) var userDefaultsSoundIOLoad: ThrowingInteractor!
    public private(set) var userDefaultsSoundIOSave: Interactor!
    public private(set) var userDefaultsRingtoneSoundNameSave: Interactor!

    public private(set) var invokedSoundIO = SoundIO(input: "", output: "", ringtoneOutput: "")
    public private(set) var invokedRingtoneSoundName = ""

    public init() {}

    public func stubWithUserAgentSoundIOSelection(interactor: ThrowingInteractor) {
        userAgentSoundIOSelection = interactor
    }

    public func stubWithUserDefaultsSoundIOLoad(interactor: ThrowingInteractor) {
        userDefaultsSoundIOLoad = interactor
    }

    public func stubWithUserDefaultsSoundIOSave(interactor: Interactor) {
        userDefaultsSoundIOSave = interactor
    }

    public func stubWithUserDefaultsRingtoneSoundNameSave(interactor: Interactor) {
        userDefaultsRingtoneSoundNameSave = interactor
    }
}

extension InteractorFactorySpy: InteractorFactory {
    public func createUserAgentSoundIOSelectionInteractor(userAgent userAgent: UserAgent) -> ThrowingInteractor {
        return userAgentSoundIOSelection
    }

    public func createUserDefaultsSoundIOLoadInteractor(output output: UserDefaultsSoundIOLoadInteractorOutput) -> ThrowingInteractor {
        return userDefaultsSoundIOLoad
    }

    public func createUserDefaultsSoundIOSaveInteractor(soundIO soundIO: SoundIO) -> Interactor {
        invokedSoundIO = soundIO
        return userDefaultsSoundIOSave
    }

    public func createUserDefaultsRingtoneSoundNameSaveInteractor(name name: String) -> Interactor {
        invokedRingtoneSoundName = name
        return userDefaultsRingtoneSoundNameSave
    }
}

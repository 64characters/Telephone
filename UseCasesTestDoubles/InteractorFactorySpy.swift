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
    public private(set) var userAgentSoundIOSelectionInteractor: ThrowingInteractor!
    public private(set) var userDefaultsSoundIOLoadInteractor: ThrowingInteractor!
    public private(set) var userDefaultsSoundIOSaveInteractor: Interactor!

    public private(set) var invokedSoundIO = SoundIO(soundInput: "", soundOutput: "", ringtoneOutput: "")

    public init() {}

    public func stubWithUserAgentSoundIOSelectionInteractor(interactor: ThrowingInteractor) {
        userAgentSoundIOSelectionInteractor = interactor
    }

    public func stubWithUserDefaultsSoundIOLoadInteractor(interactor: ThrowingInteractor) {
        userDefaultsSoundIOLoadInteractor = interactor
    }

    public func stubWithUserDefaultsSoundIOSaveInteractor(interactor: Interactor) {
        userDefaultsSoundIOSaveInteractor = interactor
    }
}

extension InteractorFactorySpy: InteractorFactory {
    public func createUserAgentSoundIOSelectionInteractorWithUserAgent(userAgent: UserAgent) -> ThrowingInteractor {
        return userAgentSoundIOSelectionInteractor
    }

    public func createUserDefaultsSoundIOLoadInteractorWithOutput(output: UserDefaultsSoundIOLoadInteractorOutput) -> ThrowingInteractor {
        return userDefaultsSoundIOLoadInteractor
    }

    public func createUserDefaultsSoundIOSaveInteractorWithSoundIO(soundIO: SoundIO) -> Interactor {
        invokedSoundIO = soundIO
        return userDefaultsSoundIOSaveInteractor
    }
}

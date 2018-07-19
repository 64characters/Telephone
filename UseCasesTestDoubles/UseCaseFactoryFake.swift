//
//  UseCaseFactoryFake.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

public final class UseCaseFactoryFake {
    public init() {}
}

extension UseCaseFactoryFake: UseCaseFactory {
    public func makeSettingsSoundIOLoadUseCase(output: SettingsSoundIOLoadUseCaseOutput) -> ThrowingUseCase {
        return ThrowingUseCaseSpy()
    }

    public func makeSettingsSoundIOSaveUseCase(inputName: String, outputName: String, ringtoneOutputName: String) -> UseCase {
        return UseCaseSpy()
    }

    public func makeSettingsRingtoneSoundNameSaveUseCase(name: String) -> UseCase {
        return UseCaseSpy()
    }
}


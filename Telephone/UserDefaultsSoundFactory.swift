//
//  UserDefaultsSoundFactory.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
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

class UserDefaultsSoundFactory {
    let soundConfigurationLoadinteractor: UserDefaultsRingtoneSoundConfigurationLoadInteractorInput
    let nsSoundToSoundAdapterFactory: NSSoundToSoundAdapterFactory

    init(soundConfigurationLoadinteractor: UserDefaultsRingtoneSoundConfigurationLoadInteractorInput, nsSoundToSoundAdapterFactory: NSSoundToSoundAdapterFactory) {
        self.soundConfigurationLoadinteractor = soundConfigurationLoadinteractor
        self.nsSoundToSoundAdapterFactory = NSSoundToSoundAdapterFactory()
    }
}

extension UserDefaultsSoundFactory: SoundFactory {
    func createSound() throws -> Sound {
        return try nsSoundToSoundAdapterFactory.createSound(try soundConfigurationLoadinteractor.execute())
    }
}

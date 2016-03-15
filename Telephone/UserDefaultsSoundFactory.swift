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
    let soundConfigurationLoadInteractor: SoundConfigurationLoadInteractor
    let nsSoundToSoundAdapterFactory: NSSoundToSoundAdapterFactory

    init(soundConfigurationLoadInteractor: SoundConfigurationLoadInteractor, nsSoundToSoundAdapterFactory: NSSoundToSoundAdapterFactory) {
        self.soundConfigurationLoadInteractor = soundConfigurationLoadInteractor
        self.nsSoundToSoundAdapterFactory = NSSoundToSoundAdapterFactory()
    }
}

extension UserDefaultsSoundFactory: SoundFactory {
    func createSound(observer observer: SoundObserver) throws -> Sound {
        return try nsSoundToSoundAdapterFactory.createSound(configuration: try soundConfigurationLoadInteractor.execute(), observer: observer)
    }
}

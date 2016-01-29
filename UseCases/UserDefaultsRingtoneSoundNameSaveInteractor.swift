//
//  UserDefaultsRingtoneSoundNameSaveInteractor.swift
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

public class UserDefaultsRingtoneSoundNameSaveInteractor {
    public let soundName: String
    public let userDefaults: UserDefaults

    public init(soundName: String, userDefaults: UserDefaults) {
        self.soundName = soundName
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsRingtoneSoundNameSaveInteractor: Interactor {
    public func execute() {
        userDefaults[kRingingSound] = soundName
    }
}

//
//  UserDefaultsSoundIOSaveInteractor.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov
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

public class UserDefaultsSoundIOSaveInteractor {
    public let soundIO: SoundIO
    public let userDefaults: UserDefaults

    public init(soundIO: SoundIO, userDefaults: UserDefaults) {
        self.soundIO = soundIO
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsSoundIOSaveInteractor: Interactor {
    public func execute() {
        userDefaults[kSoundInput] = soundIO.soundInput
        userDefaults[kSoundOutput] = soundIO.soundOutput
        userDefaults[kRingtoneOutput] = soundIO.ringtoneOutput
    }
}

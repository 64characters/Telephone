//
//  RingtoneFactoryImpl.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexei Kuznetsov.
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

public class RingtoneFactoryImpl {
    public let soundFactory: SoundFactory
    public let userDefaults: UserDefaults
    public let timerFactory: TimerFactory

    public init(soundFactory: SoundFactory, userDefaults: UserDefaults, timerFactory: TimerFactory) {
        self.soundFactory = soundFactory
        self.userDefaults = userDefaults
        self.timerFactory = timerFactory
    }
}

extension RingtoneFactoryImpl: RingtoneFactory {
    public func createRingtoneWithTimeInterval(timeInterval: Double) throws -> Ringtone {
        if let name = userDefaults[kRingingSound] {
            return try createRingtoneWithName(name, timeInterval: timeInterval)
        } else {
            throw TelephoneError.RingtoneNameNotFoundError
        }
    }

    private func createRingtoneWithName(name: String, timeInterval: Double) throws -> Ringtone {
        return RepeatingSound(
            sound: try soundFactory.createSoundWithName(name),
            timeInterval: timeInterval,
            timerFactory: timerFactory
        )
    }
}

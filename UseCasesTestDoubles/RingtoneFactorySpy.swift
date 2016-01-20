//
//  RingtoneFactorySpy.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexei Kuznetsov
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

public class RingtoneFactorySpy {
    public private(set) var createRingtoneCallCount = 0
    public private(set) var invokedTimeInterval: Double = 0
    public private(set) var ringtone: Ringtone!

    public init() {}

    public func stubWith(ringtone: Ringtone) {
        self.ringtone = ringtone
    }
}

extension RingtoneFactorySpy: RingtoneFactory {
    public func createRingtoneWithTimeInterval(timeInterval: Double) -> Ringtone {
        createRingtoneCallCount += 1
        invokedTimeInterval = timeInterval
        return ringtone
    }
}

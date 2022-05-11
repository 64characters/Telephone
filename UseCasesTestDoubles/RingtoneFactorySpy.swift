//
//  RingtoneFactorySpy.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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

public final class RingtoneFactorySpy {
    public private(set) var makeRingtoneCallCount = 0
    public private(set) var invokedInterval: Double = 0
    
    private var ringtone: Ringtone!

    public init() {}

    public func stub(with ringtone: Ringtone) {
        self.ringtone = ringtone
    }
}

extension RingtoneFactorySpy: RingtoneFactory {
    public func makeRingtone(interval: Double) -> Ringtone {
        makeRingtoneCallCount += 1
        invokedInterval = interval
        return ringtone
    }
}

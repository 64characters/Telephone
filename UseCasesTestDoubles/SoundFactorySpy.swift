//
//  SoundFactorySpy.swift
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

public class SoundFactorySpy {
    public private(set) var didCallCreateSound = false
    public private(set) var lastCreatedSound: SoundSpy!

    public init() {}
}

extension SoundFactorySpy: SoundFactory {
    public func createSound(eventTarget eventTarget: SoundEventTarget) throws -> Sound {
        didCallCreateSound = true
        lastCreatedSound = SoundSpy(eventTarget: eventTarget)
        return lastCreatedSound
    }
}

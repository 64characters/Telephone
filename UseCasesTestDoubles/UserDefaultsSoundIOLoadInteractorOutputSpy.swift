//
//  UserDefaultsSoundIOLoadInteractorOutputSpy.swift
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

public class UserDefaultsSoundIOLoadInteractorOutputSpy {
    public private(set) var invokedDevices: AudioDevices?
    public private(set) var invokedSoundIO: SoundIO?

    public init() {}
}

extension UserDefaultsSoundIOLoadInteractorOutputSpy: UserDefaultsSoundIOLoadInteractorOutput {
    public func update(devices devices: AudioDevices, soundIO: SoundIO) {
        self.invokedDevices = devices
        self.invokedSoundIO = soundIO
    }
}

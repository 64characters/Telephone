//
//  UserDefaultsSoundIOLoadInteractorOutputSpy.swift
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

import UseCases

public class UserDefaultsSoundIOLoadInteractorOutputSpy {
    public private(set) var audioDevices: AudioDevices?
    public private(set) var soundIO: SoundIO?

    public init() {}
}

extension UserDefaultsSoundIOLoadInteractorOutputSpy: UserDefaultsSoundIOLoadInteractorOutput {
    public func update(audioDevices: AudioDevices, soundIO: SoundIO) {
        self.audioDevices = audioDevices
        self.soundIO = soundIO
    }
}

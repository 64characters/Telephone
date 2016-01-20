//
//  SoundIO.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

public struct SoundIO {
    public let soundInput: AudioDevice
    public let soundOutput: AudioDevice
    public let ringtoneOutput: AudioDevice

    public init(soundInput: AudioDevice, soundOutput: AudioDevice, ringtoneOutput: AudioDevice) {
        self.soundInput = soundInput
        self.soundOutput = soundOutput
        self.ringtoneOutput = ringtoneOutput
    }
}

extension SoundIO: Equatable {}

public func ==(lhs: SoundIO, rhs: SoundIO) -> Bool {
    return lhs.soundInput == rhs.soundInput && lhs.soundOutput == rhs.soundOutput && lhs.ringtoneOutput == rhs.ringtoneOutput
}

extension SoundIO {
    init(selectedSystemSoundIO: SelectedSystemSoundIO) {
        self.init(
            soundInput: AudioDevice(systemAudioDevice: selectedSystemSoundIO.soundInput),
            soundOutput: AudioDevice(systemAudioDevice: selectedSystemSoundIO.soundOutput),
            ringtoneOutput: AudioDevice(systemAudioDevice: selectedSystemSoundIO.ringtoneOutput)
        )
    }
}

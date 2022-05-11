//
//  SimpleSoundIO.swift
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

public struct SimpleSoundIO: SoundIO {
    public let input: SystemAudioDevice
    public let output: SystemAudioDevice
    public let ringtoneOutput: SystemAudioDevice

    public init(input: SystemAudioDevice, output: SystemAudioDevice, ringtoneOutput: SystemAudioDevice) {
        self.input = input
        self.output = output
        self.ringtoneOutput = ringtoneOutput
    }
}

extension SimpleSoundIO {
    init(soundIO: SystemSoundIO) {
        self.init(
            input: soundIO.input,
            output: soundIO.output,
            ringtoneOutput: soundIO.output
        )
    }
}

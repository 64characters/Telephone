//
//  PreferredSoundIO.swift
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

public struct PreferredSoundIO: SoundIO {
    public let input: SystemAudioDevice
    public let output: SystemAudioDevice
    public let ringtoneOutput: SystemAudioDevice

    public init(devices: [SystemAudioDevice]) {
        let soundIO = createFallingBackSoundIO(devices: devices)
        input = soundIO.input
        output = soundIO.output
        ringtoneOutput = soundIO.ringtoneOutput
    }
}

private func createFallingBackSoundIO(devices devices: [SystemAudioDevice]) -> SoundIO {
    return FallingBackSoundIO(
        origin: SimpleSoundIO(soundIO: FirstBuiltInSystemSoundIO(devices: devices)),
        fallback: SimpleSoundIO(soundIO: FirstSystemSoundIO(devices: devices))
    )
}

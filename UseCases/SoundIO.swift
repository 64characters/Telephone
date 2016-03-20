//
//  SoundIO.swift
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

public struct SoundIO {
    public let input: AudioDevice
    public let output: AudioDevice
    public let ringtoneOutput: AudioDevice

    public init(input: AudioDevice, output: AudioDevice, ringtoneOutput: AudioDevice) {
        self.input = input
        self.output = output
        self.ringtoneOutput = ringtoneOutput
    }
}

extension SoundIO: Equatable {}

public func ==(lhs: SoundIO, rhs: SoundIO) -> Bool {
    return lhs.input == rhs.input && lhs.output == rhs.output && lhs.ringtoneOutput == rhs.ringtoneOutput
}

extension SoundIO {
    init(soundIO: SelectedSystemSoundIO) {
        self.init(
            input: AudioDevice(device: soundIO.input),
            output: AudioDevice(device: soundIO.output),
            ringtoneOutput: AudioDevice(device: soundIO.ringtoneOutput)
        )
    }
}

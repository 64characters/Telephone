//
//  PresentationSoundIO.swift
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

import Domain

public struct PresentationSoundIO {
    public let input: AudioDevice
    public let output: AudioDevice
    public let ringtoneOutput: AudioDevice

    public init(input: AudioDevice, output: AudioDevice, ringtoneOutput: AudioDevice) {
        self.input = input
        self.output = output
        self.ringtoneOutput = ringtoneOutput
    }
}

extension PresentationSoundIO: Equatable {}

public func ==(lhs: PresentationSoundIO, rhs: PresentationSoundIO) -> Bool {
    return lhs.input == rhs.input && lhs.output == rhs.output && lhs.ringtoneOutput == rhs.ringtoneOutput
}

extension PresentationSoundIO {
    init(soundIO: SoundIO) {
        self.init(
            input: AudioDevice(device: soundIO.input),
            output: AudioDevice(device: soundIO.output),
            ringtoneOutput: AudioDevice(device: soundIO.ringtoneOutput)
        )
    }
}

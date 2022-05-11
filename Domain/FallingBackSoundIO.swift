//
//  FallingBackSoundIO.swift
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

public struct FallingBackSoundIO {
    private let origin: SoundIO
    private let fallback: SoundIO

    public init(origin: SoundIO, fallback: SoundIO) {
        self.origin = origin
        self.fallback = fallback
    }
}

extension FallingBackSoundIO: SoundIO {
    public var input: SystemAudioDevice {
        return origin.input.isNil ? fallback.input : origin.input
    }

    public var output: SystemAudioDevice {
        return origin.output.isNil  ? fallback.output : origin.output
    }

    public var ringtoneOutput: SystemAudioDevice {
        return origin.ringtoneOutput.isNil ? fallback.ringtoneOutput : origin.ringtoneOutput
    }
}

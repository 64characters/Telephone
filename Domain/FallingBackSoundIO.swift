//
//  FallingBackSoundIO.swift
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

struct FallingBackSoundIO {
    let origin: SoundIO
    let fallback: SoundIO

    init(origin: SoundIO, fallback: SoundIO) {
        self.origin = origin
        self.fallback = fallback
    }
}

extension FallingBackSoundIO: SoundIO {
    var input: SystemAudioDevice {
        return origin.input.isNil ? fallback.input : origin.input
    }

    var output: SystemAudioDevice {
        return origin.output.isNil  ? fallback.output : origin.output
    }

    var ringtoneOutput: SystemAudioDevice {
        return output
    }
}

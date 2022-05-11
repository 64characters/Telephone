//
//  NSSoundToSoundAdapter.swift
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

import UseCases

final class NSSoundToSoundAdapter: NSObject {
    private let sound: NSSound
    private let target: SoundEventTarget

    init(sound: NSSound, target: SoundEventTarget) {
        self.sound = sound
        self.target = target
        super.init()
        self.sound.delegate = self
    }

    deinit {
        if sound.delegate === self {
            sound.delegate = nil
        }
    }
}

extension NSSoundToSoundAdapter: Sound {
    func play() {
        sound.play()
    }

    func stop() {
        sound.stop()
    }
}

extension NSSoundToSoundAdapter: NSSoundDelegate {
    func sound(_ sound: NSSound, didFinishPlaying flag: Bool) {
        target.didFinishPlaying(self)
    }
}

//
//  NSSoundToSoundAdapter.swift
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

import UseCases

class NSSoundToSoundAdapter: NSObject {
    let sound: NSSound
    let observer: SoundObserver

    init(sound: NSSound, observer: SoundObserver) {
        self.sound = sound
        self.observer = observer
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
    func sound(sound: NSSound, didFinishPlaying aBool: Bool) {
        observer.soundDidFinishPlaying()
    }
}

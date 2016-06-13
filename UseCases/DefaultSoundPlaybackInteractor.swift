//
//  DefaultSoundPlaybackInteractor.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

public class DefaultSoundPlaybackInteractor {
    public private(set) var sound: Sound?

    private let factory: SoundFactory

    public init(factory: SoundFactory) {
        self.factory = factory
    }
}

extension DefaultSoundPlaybackInteractor: SoundPlaybackInteractor {
    public func play() throws {
        sound?.stop()
        sound = try factory.createSound(eventTarget: self)
        sound!.play()
    }

    public func stop() {
        sound?.stop()
    }
}

extension DefaultSoundPlaybackInteractor: SoundEventTarget {
    public func soundDidFinishPlaying() {
        sound = nil
    }
}

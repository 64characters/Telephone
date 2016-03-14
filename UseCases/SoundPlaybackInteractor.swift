//
//  SoundPlaybackInteractor.swift
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

public protocol SoundPlaybackInteractorInput {
    func play() throws
    func stop()
}

public class SoundPlaybackInteractor {
    public let soundFactory: SoundFactory

    public private(set) var sound: Sound?

    public init(soundFactory: SoundFactory) {
        self.soundFactory = soundFactory
    }
}

extension SoundPlaybackInteractor: SoundPlaybackInteractorInput {
    public func play() throws {
        sound?.stop()
        sound = try soundFactory.createSound(observer: self)
        sound!.play()
    }

    public func stop() {
        sound?.stop()
    }
}

extension SoundPlaybackInteractor: SoundObserver {
    public func soundDidFinishPlaying() {
        sound = nil
    }
}

//
//  DefaultSoundPlaybackUseCase.swift
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

public final class DefaultSoundPlaybackUseCase {
    public private(set) var sound: Sound?

    private let factory: SoundFactory

    public init(factory: SoundFactory) {
        self.factory = factory
    }
}

extension DefaultSoundPlaybackUseCase: SoundPlaybackUseCase {
    public func play() throws {
        sound?.stop()
        sound = try factory.makeSound(target: self)
        sound!.play()
    }

    public func stop() {
        sound?.stop()
    }
}

extension DefaultSoundPlaybackUseCase: SoundEventTarget {
    public func didFinishPlaying(_ sound: Sound) {
        self.sound = nil
    }
}

//
//  ConditionalMusicPlayer.swift
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

public final class ConditionalMusicPlayer {
    fileprivate let origin: MusicPlayer
    fileprivate let defaults: MusicPlayerUserDefaults

    public init(origin: MusicPlayer, defaults: MusicPlayerUserDefaults) {
        self.origin = origin
        self.defaults = defaults
    }
}

extension ConditionalMusicPlayer: MusicPlayer {
    @objc public func pause() {
        if defaults.shouldPause {
            origin.pause()
        }
    }

    @objc public func resume() {
        if defaults.shouldPause {
            origin.resume()
        }
    }
}

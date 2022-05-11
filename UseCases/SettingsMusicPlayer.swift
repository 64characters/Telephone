//
//  SettingsMusicPlayer.swift
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

public final class SettingsMusicPlayer {
    private let origin: MusicPlayer
    private let settings: MusicPlayerSettings

    public init(origin: MusicPlayer, settings: MusicPlayerSettings) {
        self.origin = origin
        self.settings = settings
    }
}

extension SettingsMusicPlayer: MusicPlayer {
    public func pause() {
        if settings.shouldPause {
            origin.pause()
        }
    }

    public func resume() {
        if settings.shouldPause {
            origin.resume()
        }
    }
}

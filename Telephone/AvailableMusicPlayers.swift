//
//  AvailableMusicPlayers.swift
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

final class AvailableMusicPlayers {
    private let players: MusicPlayers

    init(factory: MusicPlayerFactory) {
        var players = [MusicPlayer]()
        if let p = factory.makeiTunesMusicPlayer() {
            players.append(p)
        }
        if let p = factory.makeMusicAppMusicPlayer() {
            players.append(p)
        }
        if let p = factory.makeSpotifyMusicPlayer() {
            players.append(p)
        }
        self.players = MusicPlayers(players: players)
    }
}

extension AvailableMusicPlayers: MusicPlayer {
    func pause() {
        players.pause()
    }

    func resume() {
        players.resume()
    }
}

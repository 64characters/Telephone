//
//  DefaultRingtonePlaybackInteractor.swift
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

public class DefaultRingtonePlaybackInteractor: NSObject {
    public static let ringtoneInterval: Double = 4

    public let ringtoneFactory: RingtoneFactory

    public var playing: Bool { return ringtone != nil }

    private var ringtone: Ringtone?

    public init(ringtoneFactory: RingtoneFactory) {
        self.ringtoneFactory = ringtoneFactory
    }
}

extension DefaultRingtonePlaybackInteractor: RingtonePlaybackInteractor {
    public func startPlayingRingtone() throws {
        if ringtone == nil {
            ringtone = try ringtoneFactory.createRingtone(timeInterval: DefaultRingtonePlaybackInteractor.ringtoneInterval)
        }
        ringtone!.startPlaying()
    }

    public func stopPlayingRingtone() {
        ringtone?.stopPlaying()
        ringtone = nil
    }
}

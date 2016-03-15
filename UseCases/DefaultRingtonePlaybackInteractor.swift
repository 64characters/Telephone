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
    public static let interval: Double = 4

    public let factory: RingtoneFactory

    public var playing: Bool { return ringtone != nil }

    private var ringtone: Ringtone?

    public init(factory: RingtoneFactory) {
        self.factory = factory
    }
}

extension DefaultRingtonePlaybackInteractor: RingtonePlaybackInteractor {
    public func start() throws {
        if ringtone == nil {
            ringtone = try factory.createRingtone(interval: DefaultRingtonePlaybackInteractor.interval)
        }
        ringtone!.startPlaying()
    }

    public func stop() {
        ringtone?.stopPlaying()
        ringtone = nil
    }
}

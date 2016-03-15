//
//  ConditionalRingtonePlaybackInteractor.swift
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

public class ConditionalRingtonePlaybackInteractor: NSObject {
    public let origin: RingtonePlaybackInteractor
    public let delegate: ConditionalRingtonePlaybackInteractorDelegate

    public var playing: Bool { return origin.playing }

    public init(origin: RingtonePlaybackInteractor, delegate: ConditionalRingtonePlaybackInteractorDelegate) {
        self.origin = origin
        self.delegate = delegate
    }
}

extension ConditionalRingtonePlaybackInteractor: RingtonePlaybackInteractor {
    public func start() throws {
        try origin.start()
    }

    public func stop() {
        if delegate.playbackCanStop(self) {
            origin.stop()
        }
    }
}

@objc public protocol ConditionalRingtonePlaybackInteractorDelegate {
    func playbackCanStop(playback: ConditionalRingtonePlaybackInteractor) -> Bool
}

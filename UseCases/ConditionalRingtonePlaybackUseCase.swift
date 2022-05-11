//
//  ConditionalRingtonePlaybackUseCase.swift
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

public final class ConditionalRingtonePlaybackUseCase: NSObject {
    private let origin: RingtonePlaybackUseCase
    private let delegate: ConditionalRingtonePlaybackUseCaseDelegate

    public var isPlaying: Bool { return origin.isPlaying }

    public init(origin: RingtonePlaybackUseCase, delegate: ConditionalRingtonePlaybackUseCaseDelegate) {
        self.origin = origin
        self.delegate = delegate
    }
}

extension ConditionalRingtonePlaybackUseCase: RingtonePlaybackUseCase {
    public func start() throws {
        try origin.start()
    }

    public func stop() {
        if delegate.playbackCanStop(self) {
            origin.stop()
        }
    }
}

@objc public protocol ConditionalRingtonePlaybackUseCaseDelegate {
    func playbackCanStop(_ playback: ConditionalRingtonePlaybackUseCase) -> Bool
}

//
//  RepeatingSound.swift
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

public final class RepeatingSound {
    private let sound: Sound
    public let interval: Double
    private let factory: TimerFactory
    private var timer: Timer?

    public init(sound: Sound, interval: Double, factory: TimerFactory) {
        self.sound = sound
        self.interval = interval
        self.factory = factory
    }
}

extension RepeatingSound: Ringtone {
    public func startPlaying() {
        sound.play()
        makeTimerIfNeeded()
    }

    public func stopPlaying() {
        sound.stop()
        invalidateTimerIfNeeded()
    }

    private func makeTimerIfNeeded() {
        if timer == nil {
            timer = factory.makeRepeatingTimer(interval: interval, action: sound.play)
        }
    }

    private func invalidateTimerIfNeeded() {
        timer?.invalidate()
        timer = nil
    }
}

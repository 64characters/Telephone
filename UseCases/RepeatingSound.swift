//
//  RepeatingSound.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexei Kuznetsov. All rights reserved.
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

public class RepeatingSound {
    public let sound: Sound
    public let timeInterval: Double
    public let timerFactory: TimerFactory

    private var timer: Timer?

    public init(sound: Sound, timeInterval: Double, timerFactory: TimerFactory) {
        self.sound = sound
        self.timeInterval = timeInterval
        self.timerFactory = timerFactory
    }
}

extension RepeatingSound: Ringtone {
    public func startPlaying() {
        sound.play()
        createTimerIfNeeded()
    }

    public func stopPlaying() {
        sound.stop()
        invalidateTimerIfNeeded()
    }

    private func createTimerIfNeeded() {
        if timer == nil {
            timer = timerFactory.createRepeatingTimerWithTimeInterval(timeInterval, action: sound.play)
        }
    }

    private func invalidateTimerIfNeeded() {
        timer?.invalidate()
        timer = nil
    }
}

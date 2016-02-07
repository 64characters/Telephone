//
//  TimerFactoryImpl.swift
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

import UseCases

class TimerFactoryImpl: TimerFactory {
    func createRepeatingTimerWithTimeInterval(timeInterval: Double, action: () -> Void) -> Timer {
        let timer = NSTimerToTimerAdapter(action: action)
        timer.systemTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: timer, selector: "tick", userInfo: nil, repeats: true)
        return timer
    }
}

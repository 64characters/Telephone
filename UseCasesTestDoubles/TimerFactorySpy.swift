//
//  TimerFactorySpy.swift
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

import UseCases

public class TimerFactorySpy {
    public private(set) var didCallCreateRepeatingTimer = false
    public private(set) var createRepeatingTimerCallCount = 0
    public private(set) var invokedInterval: Double = 0

    private var timer: Timer!

    public init() {}

    public func stubWith(timer: Timer) {
        self.timer = timer
    }
}

extension TimerFactorySpy: TimerFactory {
    public func createRepeatingTimer(interval interval: Double, action: () -> Void) -> Timer {
        didCallCreateRepeatingTimer = true
        createRepeatingTimerCallCount += 1
        invokedInterval = interval
        return timer
    }
}

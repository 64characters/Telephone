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

public final class TimerFactorySpy {
    public fileprivate(set) var didCallCreateRepeatingTimer = false
    public fileprivate(set) var makeRepeatingTimerCallCount = 0
    public fileprivate(set) var invokedInterval: Double = 0

    fileprivate var timer: Timer!

    public init() {}

    public func stub(with timer: Timer) {
        self.timer = timer
    }
}

extension TimerFactorySpy: TimerFactory {
    public func makeRepeatingTimer(interval: Double, action: @escaping () -> Void) -> Timer {
        didCallCreateRepeatingTimer = true
        makeRepeatingTimerCallCount += 1
        invokedInterval = interval
        return timer
    }
}

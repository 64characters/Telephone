//
//  RingtoneFactoryImplTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

class RingtoneFactoryImplTests: XCTestCase {
    private var soundFactorySpy: SoundFactorySpy!
    private var userDefaults: UserDefaultsFake!
    private var sut: RingtoneFactoryImpl!

    override func setUp() {
        super.setUp()
        soundFactorySpy = SoundFactorySpy()
        userDefaults = UserDefaultsFake()
        sut = RingtoneFactoryImpl(soundFactory: soundFactorySpy, userDefaults: userDefaults, timerFactory: TimerFactorySpy())
    }

    func testCreatesSoundWithNameFromUserDefaults() {
        userDefaults[kRingingSound] = "any-sound"

        try! sut.createRingtoneWithTimeInterval(0)

        XCTAssertEqual(soundFactorySpy.invokedName, "any-sound")
    }

    func testCreatesRingtoneWithSpecifiedTimeInterval() {
        userDefaults[kRingingSound] = "any-sound"
        let anyInterval: Double = 2

        let result = try! sut.createRingtoneWithTimeInterval(anyInterval)

        XCTAssertEqual(result.timeInterval, anyInterval)
    }

    func testThrowsIfSoundNameDoesNotExistInUserDefaults() {
        var result = false

        do {
            try sut.createRingtoneWithTimeInterval(0)
        } catch {
            result = true
        }

        XCTAssertTrue(result)
    }
}

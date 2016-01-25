//
//  RingtoneFactoryImplTests.swift
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
import UseCasesTestDoubles
import XCTest

class RingtoneFactoryImplTests: XCTestCase {
    private var interactorStub: UserDefaultsRingtoneSoundConfigurationLoadInteractorStub!
    private var soundFactorySpy: SoundFactorySpy!
    private var sut: RingtoneFactoryImpl!

    override func setUp() {
        super.setUp()
        interactorStub = UserDefaultsRingtoneSoundConfigurationLoadInteractorStub()
        soundFactorySpy = SoundFactorySpy()
        sut = RingtoneFactoryImpl(interactor: interactorStub, soundFactory: soundFactorySpy, timerFactory: TimerFactorySpy())
    }

    func testCreatesSoundWithConfigurationFromUserDefaultsRingtoneSoundConfigurationLoadInteractor() {
        let configuration = SoundConfiguration(name: "name", deviceUID: "UID")
        interactorStub.stubWith(configuration)

        try! sut.createRingtoneWithTimeInterval(0)

        XCTAssertEqual(soundFactorySpy.invokedConfiguration.name, configuration.name)
        XCTAssertEqual(soundFactorySpy.invokedConfiguration.deviceUID, configuration.deviceUID)
    }

    func testCreatesRingtoneWithSpecifiedTimeInterval() {
        interactorStub.stubWith(SoundConfiguration(name: "", deviceUID: ""))
        let interval: Double = 2

        let result = try! sut.createRingtoneWithTimeInterval(interval)

        XCTAssertEqual(result.timeInterval, interval)
    }
}

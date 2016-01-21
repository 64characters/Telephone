//
//  InteractorFactoryImplTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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

class InteractorFactoryImplTests: XCTestCase {
    var repositoryDummy: SystemAudioDeviceRepository!
    var userDefaultsDummy: UserDefaults!
    var sut: InteractorFactoryImpl!

    override func setUp() {
        super.setUp()
        repositoryDummy = SystemAudioDeviceRepositoryStub()
        userDefaultsDummy = UserDefaultsFake()
        sut = InteractorFactoryImpl(systemAudioDeviceRepository: repositoryDummy, userDefaults: userDefaultsDummy)
    }

    func testCanCreateUserAgentSoundIOSelectionInteractor() {
        let userAgentDummy = UserAgentSpy()

        let result = sut.createUserAgentSoundIOSelectionInteractorWithUserAgent(userAgentDummy) as! UserAgentSoundIOSelectionInteractor

        XCTAssertNotNil(result)
        XCTAssertTrue(result.systemAudioDeviceRepository === repositoryDummy)
        XCTAssertTrue(result.userAgent === userAgentDummy)
        XCTAssertTrue(result.userDefaults === userDefaultsDummy)
    }

    func testCanCreateUserDefaultsSoundIOLoadInteractor() {
        let outputDummy = UserDefaultsSoundIOLoadInteractorOutputSpy()

        let result = sut.createUserDefaultsSoundIOLoadInteractorWithOutput(outputDummy) as! UserDefaultsSoundIOLoadInteractor

        XCTAssertNotNil(result)
        XCTAssertTrue(result.systemAudioDeviceRepository === repositoryDummy)
        XCTAssertTrue(result.userDefaults === userDefaultsDummy)
        XCTAssertTrue(result.output === outputDummy)
    }

    func testCanCreateUserDefaultsSoundIOSaveInteractor() {
        let soundIO = SoundIO(soundInput: "input", soundOutput: "output1", ringtoneOutput: "output2")

        let result = sut.createUserDefaultsSoundIOSaveInteractorWithSoundIO(soundIO) as! UserDefaultsSoundIOSaveInteractor

        XCTAssertNotNil(result)
        XCTAssertEqual(result.soundIO, soundIO)
        XCTAssertTrue(result.userDefaults === userDefaultsDummy)
    }
}

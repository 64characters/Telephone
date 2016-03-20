//
//  DefaultInteractorFactoryTests.swift
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

class DefaultInteractorFactoryTests: XCTestCase {
    var repositoryDummy: SystemAudioDeviceRepository!
    var userDefaults: UserDefaults!
    var sut: DefaultInteractorFactory!

    override func setUp() {
        super.setUp()
        repositoryDummy = SystemAudioDeviceRepositoryStub()
        userDefaults = UserDefaultsFake()
        sut = DefaultInteractorFactory(systemAudioDeviceRepository: repositoryDummy, userDefaults: userDefaults)
    }

    func testCanCreateUserAgentSoundIOSelectionInteractor() {
        let userAgentDummy = UserAgentSpy()

        let result = sut.createUserAgentSoundIOSelectionInteractor(userAgent: userAgentDummy) as! UserAgentSoundIOSelectionInteractor

        XCTAssertNotNil(result)
        XCTAssertTrue(result.repository === repositoryDummy)
        XCTAssertTrue(result.userAgent === userAgentDummy)
        XCTAssertTrue(result.userDefaults === userDefaults)
    }

    func testCanCreateUserDefaultsSoundIOLoadInteractor() {
        let outputDummy = UserDefaultsSoundIOLoadInteractorOutputSpy()

        let result = sut.createUserDefaultsSoundIOLoadInteractor(output: outputDummy) as! UserDefaultsSoundIOLoadInteractor

        XCTAssertNotNil(result)
        XCTAssertTrue(result.systemAudioDeviceRepository === repositoryDummy)
        XCTAssertTrue(result.userDefaults === userDefaults)
        XCTAssertTrue(result.output === outputDummy)
    }

    func testCanCreateUserDefaultsSoundIOSaveInteractor() {
        let soundIO = SoundIO(input: "input", output: "output1", ringtoneOutput: "output2")

        let result = sut.createUserDefaultsSoundIOSaveInteractor(soundIO: soundIO) as! UserDefaultsSoundIOSaveInteractor

        XCTAssertNotNil(result)
        XCTAssertEqual(result.soundIO, soundIO)
        XCTAssertTrue(result.userDefaults === userDefaults)
    }

    func testCanCreateUserDefaultsRingtoneSoundNameSaveInteractor() {
        let result = sut.createUserDefaultsRingtoneSoundNameSaveInteractor(name: "sound-name") as! UserDefaultsRingtoneSoundNameSaveInteractor

        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "sound-name")
        XCTAssertTrue(result.userDefaults === userDefaults)
    }
}

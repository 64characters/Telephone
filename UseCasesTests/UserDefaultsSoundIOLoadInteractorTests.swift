//
//  UserDefaultsSoundIOLoadInteractorTests.swift
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

import Domain
import DomainTestDoubles
@testable import UseCases
import UseCasesTestDoubles
import XCTest

class UserDefaultsSoundIOLoadInteractorTests: XCTestCase {
    private var audioDeviceFactory: SystemAudioDeviceTestFactory!
    private var systemAudioDevices: SystemAudioDevices!
    private var audioDeviceRepositoryStub: SystemAudioDeviceRepositoryStub!
    private var userDefaultsDummy: UserDefaultsFake!
    private var outputSpy: UserDefaultsSoundIOLoadInteractorOutputSpy!

    override func setUp() {
        super.setUp()
        audioDeviceFactory = SystemAudioDeviceTestFactory()
        systemAudioDevices = SystemAudioDevices(devices: audioDeviceFactory.allDevices)
        audioDeviceRepositoryStub = SystemAudioDeviceRepositoryStub()
        audioDeviceRepositoryStub.allDevicesResult = audioDeviceFactory.allDevices
        userDefaultsDummy = UserDefaultsFake()
        outputSpy = UserDefaultsSoundIOLoadInteractorOutputSpy()
    }

    func testCallsOutputWithExpectedAudioDevicesAndSoundIO() {
        let sut = UserDefaultsSoundIOLoadInteractor(
            repository: audioDeviceRepositoryStub,
            userDefaults: userDefaultsDummy,
            output: outputSpy
        )

        try! sut.execute()

        XCTAssertEqual(outputSpy.invokedDevices, expectedAudioDevices())
        XCTAssertEqual(outputSpy.invokedSoundIO, expectedSoundIO())
    }

    private func expectedSoundIO() -> SoundIO {
        let firstBuiltInInput = AudioDevice(device: audioDeviceFactory.firstBuiltInInput)
        let firstBuiltInOutput = AudioDevice(device: audioDeviceFactory.firstBuiltInOutput)
        return SoundIO(input: firstBuiltInInput, output: firstBuiltInOutput, ringtoneOutput: firstBuiltInOutput)
    }

    private func expectedAudioDevices() -> AudioDevices {
        return AudioDevices(devices: systemAudioDevices)
    }
}

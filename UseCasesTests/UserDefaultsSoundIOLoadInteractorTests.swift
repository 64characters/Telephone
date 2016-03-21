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
    private var factory: SystemAudioDeviceTestFactory!
    private var devices: SystemAudioDevices!
    private var repository: SystemAudioDeviceRepositoryStub!
    private var userDefaults: UserDefaultsFake!
    private var output: UserDefaultsSoundIOLoadInteractorOutputSpy!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        devices = SystemAudioDevices(devices: factory.allDevices)
        repository = SystemAudioDeviceRepositoryStub()
        repository.allDevicesResult = factory.allDevices
        userDefaults = UserDefaultsFake()
        output = UserDefaultsSoundIOLoadInteractorOutputSpy()
    }

    func testCallsOutputWithExpectedAudioDevicesAndSoundIO() {
        let sut = UserDefaultsSoundIOLoadInteractor(
            repository: repository,
            userDefaults: userDefaults,
            output: output
        )

        try! sut.execute()

        XCTAssertEqual(output.invokedDevices, expectedAudioDevices())
        XCTAssertEqual(output.invokedSoundIO, expectedSoundIO())
    }

    private func expectedSoundIO() -> SoundIO {
        let firstBuiltInInput = AudioDevice(device: factory.firstBuiltInInput)
        let firstBuiltInOutput = AudioDevice(device: factory.firstBuiltInOutput)
        return SoundIO(input: firstBuiltInInput, output: firstBuiltInOutput, ringtoneOutput: firstBuiltInOutput)
    }

    private func expectedAudioDevices() -> AudioDevices {
        return AudioDevices(devices: devices)
    }
}

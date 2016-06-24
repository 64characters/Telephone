//
//  UserDefaultsSoundIOLoadUseCaseTests.swift
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

import Domain
import DomainTestDoubles
@testable import UseCases
import UseCasesTestDoubles
import XCTest

class UserDefaultsSoundIOLoadUseCaseTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!
    private var devices: SystemAudioDevices!
    private var repository: SystemAudioDeviceRepositoryStub!
    private var userDefaults: UserDefaultsFake!
    private var output: UserDefaultsSoundIOLoadUseCaseOutputSpy!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        devices = SystemAudioDevices(devices: factory.all)
        repository = SystemAudioDeviceRepositoryStub()
        repository.allDevicesResult = factory.all
        userDefaults = UserDefaultsFake()
        output = UserDefaultsSoundIOLoadUseCaseOutputSpy()
    }

    func testCallsOutputWithExpectedAudioDevicesAndSoundIO() {
        let sut = UserDefaultsSoundIOLoadUseCase(
            repository: repository,
            userDefaults: userDefaults,
            output: output
        )

        try! sut.execute()

        XCTAssertEqual(output.invokedDevices, expectedAudioDevices())
        XCTAssertEqual(output.invokedSoundIO, expectedSoundIO())
    }

    private func expectedSoundIO() -> PresentationSoundIO {
        return PresentationSoundIO(
            input: AudioDevice(device: factory.firstBuiltInInput),
            output: AudioDevice(device: factory.firstBuiltInOutput),
            ringtoneOutput: AudioDevice(device: factory.firstBuiltInOutput)
        )
    }

    private func expectedAudioDevices() -> AudioDevices {
        return AudioDevices(devices: devices)
    }
}

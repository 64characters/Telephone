//
//  SettingsSoundIOLoadUseCaseTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

final class SettingsSoundIOLoadUseCaseTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!
    private var devices: SystemAudioDevices!
    private var repository: SystemAudioDeviceRepositoryStub!
    private var settings: SettingsFake!
    private var output: SettingsSoundIOLoadUseCaseOutputSpy!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        devices = SystemAudioDevices(devices: factory.all)
        repository = SystemAudioDeviceRepositoryStub()
        repository.allDevicesResult = factory.all
        settings = SettingsFake()
        output = SettingsSoundIOLoadUseCaseOutputSpy()
    }

    func testCallsOutputWithExpectedAudioDevicesAndSoundIO() {
        let sut = SettingsSoundIOLoadUseCase(
            repository: repository, settings: settings, output: output
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

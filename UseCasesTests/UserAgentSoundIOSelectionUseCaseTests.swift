//
//  UserAgentSoundIOSelectionUseCaseTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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
import UseCases
import UseCasesTestDoubles
import XCTest

final class UserAgentSoundIOSelectionUseCaseTests: XCTestCase {
    func testSelectsMappedAudioDevices() {
        let factory = SystemAudioDeviceTestFactory()
        let systemDevices = SimpleSystemAudioDevices(devices: [factory.firstBuiltInInput, factory.firstBuiltInOutput])
        let repository = SystemAudioDeviceRepositoryStub()
        repository.allResult = systemDevices.all
        let userAgentDevices = [
            UserAgentAudioDevice(device: factory.firstBuiltInOutput),
            UserAgentAudioDevice(device: factory.firstBuiltInInput)
        ]
        let userAgent = UserAgentSpy()
        userAgent.audioDevicesResult = userAgentDevices
        let sut = UserAgentSoundIOSelectionUseCase(
            repository: repository, userAgent: userAgent, settings: SettingsFake()
        )

        try! sut.execute()

        XCTAssertEqual(userAgent.invokedInputDeviceID, userAgentDevices[1].identifier)
        XCTAssertEqual(userAgent.invokedOutputDeviceID, userAgentDevices[0].identifier)
    }
}

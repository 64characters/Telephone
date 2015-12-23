//
//  UserAgentAudioDeviceSelectionInteractorTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Domain
import DomainTestDoubles
import UseCases
import UseCasesTestDoubles
import XCTest

class UserAgentAudioDeviceSelectionInteractorTests: XCTestCase {
    private var systemDevices: SystemAudioDevices!
    private var repositoryStub: SystemAudioDeviceRepositoryStub!
    private var userAgentSpy: UserAgentSpy!
    private var userDefaultsDummy: UserDefaultsFake!
    private var sut: UserAgentAudioDeviceSelectionInteractor!

    override func setUp() {
        super.setUp()
        systemDevices = createSystemDevices()
        repositoryStub = SystemAudioDeviceRepositoryStub()
        repositoryStub.allDevicesResult = systemDevices.allDevices
        userAgentSpy = UserAgentSpy()
        userAgentSpy.audioDevicesResult = createUserAgentDevices()
        userDefaultsDummy = UserDefaultsFake()
        sut = createInteractor()
    }

    func testSelectsMappedAudioDevices() {
        try! sut.execute()

        let userAgentDevices: [UseCases.UserAgentAudioDevice] = userAgentSpy.audioDevicesResult
        XCTAssertEqual(userAgentSpy.selectedInputDeviceID, userAgentDevices[1].identifier)
        XCTAssertEqual(userAgentSpy.selectedOutputDeviceID, userAgentDevices[0].identifier)
    }

    private func createSystemDevices() -> SystemAudioDevices {
        let factory = SystemAudioDeviceTestFactory()
        return SystemAudioDevices(devices: [factory.firstBuiltInInput, factory.firstBuiltInOutput])
    }

    private func createUserAgentDevices() -> [UseCases.UserAgentAudioDevice] {
        let device1 = UseCases.UserAgentAudioDevice(identifier: 1, name: systemDevices.allDevices[1].name)
        let device2 = UseCases.UserAgentAudioDevice(identifier: 2, name: systemDevices.allDevices[0].name)
        return [device1, device2]
    }

    private func createInteractor() -> UserAgentAudioDeviceSelectionInteractor {
        return UserAgentAudioDeviceSelectionInteractor(systemAudioDeviceRepository: repositoryStub, userAgent: userAgentSpy, userDefaults: userDefaultsDummy)
    }
}

//
//  UserAgentAudioDeviceUpdaterTests.swift
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

import UseCasesTestDoubles
import XCTest

class UserAgentAudioDeviceUpdaterTests: XCTestCase {
    var interactorSpy: ThrowingInteractorSpy!
    var sut: UserAgentAudioDeviceUpdater!

    override func setUp() {
        super.setUp()
        interactorSpy = ThrowingInteractorSpy()
        sut = UserAgentAudioDeviceUpdater(interactor: interactorSpy)
    }

    func testExecutesInteractorWhenUpdateAudioDevicesIsCalled() {
        try! sut.updateAudioDevices()

        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesInteractorWhenSystemAudioDevicesAreUpdated() {
        sut.systemAudioDevicesDidUpdate()

        XCTAssertTrue(interactorSpy.didCallExecute)
    }
}

//
//  PreferredSoundIOTests.swift
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

final class PreferredSoundIOTests: XCTestCase {
    private var factory: SystemAudioDeviceTestFactory!
    private var defaults: UserDefaultsFake!

    override func setUp() {
        super.setUp()
        factory = SystemAudioDeviceTestFactory()
        defaults = UserDefaultsFake()
    }

    // MARK: - Sound input

    func testInputIsDeviceWithNameFromUserDefaults() {
        let someDevice = factory.someInput
        defaults[kSoundInput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == someDevice)
    }

    func testInputIsBuiltInInputWhenThereIsNoSoundInputInUserDefaults() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenSoundInputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        defaults[kSoundInput] = kNonexistentDeviceName

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsBuiltInInputWhenAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveInputChannels() {
        defaults[kSoundInput] = factory.outputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.input == factory.firstBuiltInInput)
    }

    func testInputIsFirstInputWhenNotFoundInUserDefaultsAndThereIsNoBuiltInInput() {
        let sut = makeSoundIO(devices: [factory.firstInput, factory.someOutput])

        XCTAssertTrue(sut.input == factory.firstInput)
    }

    // MARK: - Sound output

    func testOutputIsDeviceWithNameFromUserDefaults() {
        let someDevice = factory.someOutput
        defaults[kSoundOutput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == someDevice)
    }

    func testOutputIsBuiltInOutputWhenThereIsNoSoundOutputInUserDefaults() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenSoundOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        defaults[kSoundOutput] = kNonexistentDeviceName

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        defaults[kSoundOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.output == factory.firstBuiltInOutput)
    }

    func testOutputIsFirstOutputWhenNotFoundInUserDefaultsAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput])

        XCTAssertTrue(sut.output == factory.firstOutput)
    }

    // MARK: - Ringtone output

    func testRingtoneOutputIsDeviceWithNameFromUserDefaults() {
        let someDevice = factory.someOutput
        defaults[kRingtoneOutput] = someDevice.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == someDevice)
    }

    func testRingtoneOutputIsBuiltInOutputWhenThereIsNoRingtoneOutputInUserDefaults() {
        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenRingtoneOutputFromUserDefaultsCanNotBeFoundInSystemDevices() {
        let sut = makeSoundIO()

        defaults[kRingtoneOutput] = kNonexistentDeviceName

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsBuiltInOutputWhenAudioDeviceMatchedByNameFromUserDefaultsDoesNotHaveOutputChannels() {
        defaults[kRingtoneOutput] = factory.inputOnly.name

        let sut = makeSoundIO()

        XCTAssertTrue(sut.ringtoneOutput == factory.firstBuiltInOutput)
    }

    func testRingtoneOutputIsFirstOutputWhenNotFoundInUserDefaultsAndThereIsNoBuiltInOutput() {
        let sut = makeSoundIO(devices: [factory.someInput, factory.firstOutput])

        XCTAssertTrue(sut.ringtoneOutput == factory.firstOutput)
    }

    // MARK: - Helper

    private func makeSoundIO() -> UseCases.PreferredSoundIO {
        return makeSoundIO(devices: factory.all)
    }

    private func makeSoundIO(devices: [SystemAudioDevice]) -> UseCases.PreferredSoundIO {
        return PreferredSoundIO(devices: SystemAudioDevices(devices: devices), defaults: defaults)
    }
}

private let kNonexistentDeviceName = "Nonexistent"

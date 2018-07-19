//
//  SoundIOPresenterTests.swift
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
import XCTest

final class SoundIOPresenterTests: XCTestCase {
    func testUpdatesOutputWithPresentationSoundIOAndAudioDevices() {
        let output = SoundPreferencesViewSpy()
        let sut = SoundIOPresenter(output: output)
        let factory = SystemAudioDeviceTestFactory()
        let soundIO = SimpleSoundIO(input: factory.someInput, output: factory.firstOutput, ringtoneOutput: factory.someOutput)
        let devices = SystemAudioDevices(devices: factory.all)
        let presentationIO = PresentationSoundIO(soundIO: soundIO)
        let presentationDevices = PresentationAudioDevices(devices: devices)

        sut.update(soundIO: soundIO, devices: devices)

        XCTAssertEqual(output.invokedInputDevice, presentationIO.input)
        XCTAssertEqual(output.invokedOutputDevice,  presentationIO.output)
        XCTAssertEqual(output.invokedRingtoneDevice, presentationIO.ringtoneOutput)
        XCTAssertEqual(output.invokedInputDevices, presentationDevices.input)
        XCTAssertEqual(output.invokedOutputDevices, presentationDevices.output)
        XCTAssertEqual(output.invokedRingtoneDevices, presentationDevices.output)
    }
}

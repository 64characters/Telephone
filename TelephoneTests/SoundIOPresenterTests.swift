//
//  SoundIOPresenterTests.swift
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
import XCTest

class SoundIOPresenterTests: XCTestCase {
    func testUpdatesViewWithExpectedData() {
        let output = SoundPreferencesViewSpy()
        let sut = SoundIOPresenter(output: output)
        let inputDevices = ["input1", "input2"]
        let outputDevices = ["output1", "output2"]
        let devices = AudioDevices(input: inputDevices, output: outputDevices)
        let soundIO = PresentationSoundIO(input: "input2", output: "output2", ringtoneOutput: "output1")

        sut.update(devices: devices, soundIO: soundIO)

        XCTAssertEqual(output.invokedInputDevices, inputDevices)
        XCTAssertEqual(output.invokedOutputDevices, outputDevices)
        XCTAssertEqual(output.invokedRingtoneDevices, outputDevices)
        XCTAssertEqual(output.invokedInputDevice, "input2")
        XCTAssertEqual(output.invokedOutputDevice, "output2")
        XCTAssertEqual(output.invokedRingtoneDevice, "output1")
    }
}

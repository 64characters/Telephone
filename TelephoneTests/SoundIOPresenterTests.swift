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
        let spy = SoundPreferencesViewSpy()
        let sut = SoundIOPresenter(output: spy)
        let input = ["input1", "input2"]
        let output = ["output1", "output2"]
        let devices = AudioDevices(input: input, output: output)
        let soundIO = SoundIO(soundInput: "input2", soundOutput: "output2", ringtoneOutput: "output1")

        sut.update(devices, soundIO: soundIO)

        XCTAssertEqual(spy.invokedInputDevices, input)
        XCTAssertEqual(spy.invokedOutputDevices, output)
        XCTAssertEqual(spy.invokedRingtoneDevices, output)
        XCTAssertEqual(spy.invokedInputDevice, "input2")
        XCTAssertEqual(spy.invokedOutputDevice, "output2")
        XCTAssertEqual(spy.invokedRingtoneDevice, "output1")
    }
}

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
        let outputSpy = SoundPreferencesViewSpy()
        let sut = SoundIOPresenter(output: outputSpy)
        let inputDevices = ["input1", "input2"]
        let outputDevices = ["output1", "output2"]
        let audioDevices = AudioDevices(inputDevices: inputDevices, outputDevices: outputDevices)
        let soundIO = SoundIO(soundInput: "input2", soundOutput: "output2", ringtoneOutput: "output1")

        sut.update(audioDevices, soundIO: soundIO)

        XCTAssertEqual(outputSpy.invokedInputAudioDevices, inputDevices)
        XCTAssertEqual(outputSpy.invokedOutputAudioDevices, outputDevices)
        XCTAssertEqual(outputSpy.invokedRingtoneOutputAudioDevices, outputDevices)
        XCTAssertEqual(outputSpy.invokedSoundInputDevice, "input2")
        XCTAssertEqual(outputSpy.invokedSoundOutputDevice, "output2")
        XCTAssertEqual(outputSpy.invokedRingtoneOutputDevice, "output1")
    }
}

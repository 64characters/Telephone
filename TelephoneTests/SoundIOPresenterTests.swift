//
//  SoundIOPresenterTests.swift
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

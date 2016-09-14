//
//  FallingBackSoundIOTests.swift
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

@testable import Domain
import DomainTestDoubles
import XCTest

final class FallingBackSoundIOTests: XCTestCase {
    fileprivate var anyDevice: SystemAudioDevice!

    override func setUp() {
        super.setUp()
        anyDevice = SystemAudioDeviceTestFactory().someInput
    }

    func testDoesNotFallBackWhenOriginHasNonNullValues() {
        let sut = FallingBackSoundIO(
            origin: createNonNullSoundIO(),
            fallback: createNullSoundIO()
        )

        assertNonNullValues(sut)
    }

    func testFallsBackWhenOriginHasNullValues() {
        let sut = FallingBackSoundIO(
            origin: createNullSoundIO(),
            fallback: createNonNullSoundIO()
        )

        assertNonNullValues(sut)
    }

    fileprivate func createNonNullSoundIO() -> SoundIO {
        return SimpleSoundIO(
            soundIO: SimpleSystemSoundIO(
                input: anyDevice, output: anyDevice
            )
        )
    }

    fileprivate func createNullSoundIO() -> SoundIO {
        return SimpleSoundIO(
            input: NullSystemAudioDevice(),
            output: NullSystemAudioDevice(),
            ringtoneOutput: NullSystemAudioDevice()
        )
    }

    fileprivate func assertNonNullValues(_ sut: FallingBackSoundIO) {
        XCTAssertTrue(sut.input == anyDevice)
        XCTAssertTrue(sut.output == anyDevice)
        XCTAssertTrue(sut.ringtoneOutput == anyDevice)
    }
}

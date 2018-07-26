//
//  SystemDefaultSoundIOTests.swift
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
@testable import UseCases
import UseCasesTestDoubles
import XCTest

final class SystemDefaultSoundIOTests: XCTestCase {
    func testSoundIOIsDevicesWhenDevicesAreNotNil() {
        let factory = SystemAudioDeviceTestFactory()
        let input = factory.someInput
        let output = factory.firstOutput
        let ringtoneOutput = factory.someOutput

        let sut = SystemDefaultSoundIO(SimpleSoundIO(input: input, output: output, ringtoneOutput: ringtoneOutput))

        XCTAssertEqual(sut.input, .device(input))
        XCTAssertEqual(sut.output, .device(output))
        XCTAssertEqual(sut.ringtoneOutput, .device(ringtoneOutput))
    }

    func testSoundIOIsSystemDefaultsWhenDevicesAreNil() {
        let sut = SystemDefaultSoundIO(NullSoundIO())

        XCTAssertEqual(sut.input, .systemDefault)
        XCTAssertEqual(sut.output, .systemDefault)
        XCTAssertEqual(sut.ringtoneOutput, .systemDefault)
    }
}

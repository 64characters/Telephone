//
//  SystemDefaultSoundIOTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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

final class SystemDefaultingSoundIOTests: XCTestCase {
    func testSoundIOIsDevicesWhenDevicesAreNotNil() {
        let factory = SystemAudioDeviceTestFactory()
        let input = factory.someInput
        let output = factory.firstOutput
        let ringtoneOutput = factory.someOutput

        let sut = SystemDefaultingSoundIO(SimpleSoundIO(input: input, output: output, ringtoneOutput: ringtoneOutput))

        XCTAssertEqual(sut.input, .device(name: input.name))
        XCTAssertEqual(sut.output, .device(name: output.name))
        XCTAssertEqual(sut.ringtoneOutput, .device(name: ringtoneOutput.name))
    }

    func testSoundIOIsSystemDefaultsWhenDevicesAreNil() {
        let sut = SystemDefaultingSoundIO(NullSoundIO())

        XCTAssertEqual(sut.input, .systemDefault)
        XCTAssertEqual(sut.output, .systemDefault)
        XCTAssertEqual(sut.ringtoneOutput, .systemDefault)
    }
}

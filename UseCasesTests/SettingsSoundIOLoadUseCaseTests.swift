//
//  SettingsSoundIOLoadUseCaseTests.swift
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

final class SettingsSoundIOLoadUseCaseTests: XCTestCase {
    func testCallsOutputWithSystemDefaultSoundIOCreatedFromSettingsSoundIOAndAllAudioDevices() throws {
        let factory = SystemAudioDevicesTestFactory(factory: SystemAudioDeviceTestFactory())
        let output = SettingsSoundIOLoadUseCaseOutputSpy()
        let sut = SettingsSoundIOLoadUseCase(factory: factory, settings: SettingsFake(), output: output)

        try sut.execute()

        XCTAssertTrue(
            output.invokedSoundIO! == SystemDefaultingSoundIO(
                SettingsSoundIO(devices: try factory.make(), settings: SettingsFake())
            )
        )
        XCTAssertEqual(output.invokedDevices, try factory.make())
    }
}

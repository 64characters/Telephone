//
//  SimpleMusicPlayerSettingsTests.swift
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

import Testing
import UseCases
import UseCasesTestDoubles

@MainActor
struct SimpleMusicPlayerSettingsTests {
    @Test func getsFromSettingsWithExpectedKey() {
        let settings = SettingsFake()
        settings.set(true, forKey: SettingsKeys.pauseITunes)
        let sut = SimpleMusicPlayerSettings(settings: settings)

        #expect(sut.shouldPause)
    }

    @Test func setsToSettingsWithExpectedKey() {
        let settings = SettingsFake()
        let sut = SimpleMusicPlayerSettings(settings: settings)

        sut.shouldPause = true

        #expect(settings.bool(forKey: SettingsKeys.pauseITunes))
    }
}

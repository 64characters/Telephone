//
//  DefaultAppSettingsTests.swift
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

import XCTest
import UseCasesTestDoubles

final class DefaultAppSettingsTests: XCTestCase {
    func testRegistersDefaultSettingsOnRegister() {
        let settings = SettingsFake()
        let sut = DefaultAppSettings(settings: settings, localization: "any")

        sut.register()

        XCTAssertFalse(settings.registeredDefaults.isEmpty)
    }

    func testFormatTelephoneNumbersIsFalseForGermanLocalization() {
        let settings = SettingsFake()
        let sut = DefaultAppSettings(settings: settings, localization: "de")

        sut.register()

        XCTAssertFalse(settings.registeredDefaults[UserDefaultsKeys.formatTelephoneNumbers] as! Bool)
    }

    func testTelephoneNumberFormatterSplitsLastFourDigitsIsTrueForRussian() {
        let settings = SettingsFake()
        let sut = DefaultAppSettings(settings: settings, localization: "ru")

        sut.register()

        XCTAssertTrue(settings.registeredDefaults[UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits] as! Bool)
    }
}

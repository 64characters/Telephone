//
//  UserDefaultsRingtoneSoundNameSaveUseCaseTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

final class UserDefaultsRingtoneSoundNameSaveUseCaseTests: XCTestCase {
    func testUpdatesUserDefaults() {
        let userDefaults = UserDefaultsFake()
        let sut = UserDefaultsRingtoneSoundNameSaveUseCase(name: "sound-name", userDefaults: userDefaults)

        sut.execute()

        XCTAssertEqual(userDefaults[kRingingSound], "sound-name")
    }

    func testDoesNotUpdateUserDefaultsWithEmptyName() {
        let userDefaults = UserDefaultsFake()
        let anyValue = "any-value"
        userDefaults[kRingingSound] = anyValue
        let sut = UserDefaultsRingtoneSoundNameSaveUseCase(name: "", userDefaults: userDefaults)

        sut.execute()

        XCTAssertEqual(userDefaults[kRingingSound], anyValue)
    }
}

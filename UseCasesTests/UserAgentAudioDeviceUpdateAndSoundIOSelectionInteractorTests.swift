//
//  UserAgentAudioDeviceUpdateAndSoundIOSelectionInteractorTests.swift
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

class UserAgentAudioDeviceUpdateAndSoundIOSelectionInteractorTests: XCTestCase {
    func testUpdatesAndSelects() {
        let update = InteractorSpy()
        let selection = ThrowingInteractorSpy()
        let sut = UserAgentAudioDeviceUpdateAndSoundIOSelectionInteractor(update: update, selection: selection)

        try! sut.execute()

        XCTAssertTrue(update.didCallExecute)
        XCTAssertTrue(selection.didCallExecute)
    }
}

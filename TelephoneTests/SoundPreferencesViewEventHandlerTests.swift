//
//  SoundPreferencesViewEventHandlerTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

import UseCasesTestDoubles
import XCTest

class SoundPreferencesViewEventHandlerTests: XCTestCase {
    private var interactorFactorySpy: InteractorFactorySpy!
    private var sut: SoundPreferencesViewEventHandler!

    override func setUp() {
        super.setUp()
        interactorFactorySpy = InteractorFactorySpy()
        sut = SoundPreferencesViewEventHandler(
            interactorFactory: interactorFactorySpy, presenterFactory: PresenterFactoryImpl(), userAgent: UserAgentSpy()
        )
    }

    func testExecutesInteractorOnViewDataReload() {
        let interactorSpy = ThrowingInteractorSpy()
        interactorFactorySpy.stubWithUserDefaultsSoundIOLoadInteractor(interactorSpy)

        sut.viewShouldReloadData(SoundPreferencesViewSpy())

        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesUserDefaultsSoundIOSaveInteractorWithExpectedArgumentsOnSoundIOChange() {
        let interactorSpy = InteractorSpy()
        interactorFactorySpy.stubWithUserDefaultsSoundIOSaveInteractor(interactorSpy)
        interactorFactorySpy.stubWithUserAgentSoundIOSelectionInteractor(ThrowingInteractorSpy())
        let soundIO = SoundIO(soundInput: "input", soundOutput: "output1", ringtoneOutput: "output2")

        sut.viewDidChangeSoundInput(
            soundIO.soundInput, soundOutput: soundIO.soundOutput, ringtoneOutput: soundIO.ringtoneOutput
        )

        XCTAssertEqual(interactorFactorySpy.invokedSoundIO, soundIO)
        XCTAssertTrue(interactorSpy.didCallExecute)
    }

    func testExecutesUserAgentSoundIOSelectionInteractorOnSoundIOChange() {
        let interactorSpy = ThrowingInteractorSpy()
        interactorFactorySpy.stubWithUserAgentSoundIOSelectionInteractor(interactorSpy)
        interactorFactorySpy.stubWithUserDefaultsSoundIOSaveInteractor(InteractorSpy())

        sut.viewDidChangeSoundInput("", soundOutput: "", ringtoneOutput: "")

        XCTAssertTrue(interactorSpy.didCallExecute)
    }
}

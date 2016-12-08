//
//  WorkspaceSleepStatusTests.swift
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

import XCTest

final class WorkspaceSleepStatusTests: XCTestCase {
    func testIsNotSleepingAfterCreation() {
        let sut = WorkspaceSleepStatus(workspace: NSWorkspace.shared())

        XCTAssertFalse(sut.isSleeping)
    }

    func testIsSleepingAfterWillSleepNotification() {
        let sut = WorkspaceSleepStatus(workspace: NSWorkspace.shared())
        let nc = NSWorkspace.shared().notificationCenter

        nc.post(name: .NSWorkspaceWillSleep, object: NSWorkspace.shared())

        XCTAssertTrue(sut.isSleeping)
    }

    func testIsNotSleepingAfterDidWakeNotification() {
        let sut = WorkspaceSleepStatus(workspace: NSWorkspace.shared())
        let nc = NSWorkspace.shared().notificationCenter

        nc.post(name: .NSWorkspaceWillSleep, object: NSWorkspace.shared())
        nc.post(name: .NSWorkspaceDidWake, object: NSWorkspace.shared())

        XCTAssertFalse(sut.isSleeping)
    }
}

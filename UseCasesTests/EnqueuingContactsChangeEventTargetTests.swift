//
//  EnqueuingContactsChangeEventTargetTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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
import UseCases
import UseCasesTestDoubles

final class EnqueuingContactsChangeEventTargetTests: XCTestCase {
    func testAddsBlockToQueueOnContactsDidChange() {
        let queue = ExecutionQueueSpy()
        let sut = EnqueuingContactsChangeEventTarget(origin: ContactsChangeEventTargetSpy(), queue: queue)

        sut.contactsDidChange()

        XCTAssertTrue(queue.didCallAdd)
    }

    func testCallsContactsDidChangeOnOriginOnContactsDidChange() {
        let origin = ContactsChangeEventTargetSpy()
        let sut = EnqueuingContactsChangeEventTarget(origin: origin, queue: SyncExecutionQueue())

        sut.contactsDidChange()

        XCTAssertTrue(origin.didCallContactsDidChange)
    }
}

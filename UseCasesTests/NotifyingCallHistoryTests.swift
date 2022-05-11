//
//  NotifyingCallHistoryTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

final class NotifyingCallHistoryTests: XCTestCase {
    func testNotifiesTargetAfterAdding() {
        let target = CallHistoryEventTargetSpy()
        let sut = NotifyingCallHistory(origin: TruncatingCallHistory())
        sut.updateTarget(target)
        let factory = CallHistoryRecordTestFactory()

        sut.add(factory.makeRecord(number: 1))

        XCTAssertTrue(target.didCallDidUpdate)
    }

    func testNotifiesTargetAfterRemovingIndividual() {
        let target = CallHistoryEventTargetSpy()
        let sut = NotifyingCallHistory(origin: TruncatingCallHistory())
        sut.updateTarget(target)
        let record = CallHistoryRecordTestFactory().makeRecord(number: 1)

        sut.add(record)
        sut.remove(record)

        XCTAssertEqual(target.didUpdateCallCount, 2)
    }

    func testNotifiesTargetAfterRemovingAll() {
        let target = CallHistoryEventTargetSpy()
        let sut = NotifyingCallHistory(origin: TruncatingCallHistory())
        sut.updateTarget(target)
        let factory = CallHistoryRecordTestFactory()

        sut.add(factory.makeRecord(number: 1))
        sut.add(factory.makeRecord(number: 2))
        sut.removeAll()

        XCTAssertEqual(target.didUpdateCallCount, 3)
    }
}

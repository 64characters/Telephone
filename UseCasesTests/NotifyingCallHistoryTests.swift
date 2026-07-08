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

import Testing
import UseCases
import UseCasesTestDoubles

@CallHistoryActor
struct NotifyingCallHistoryTests {
    @Test func notifiesTargetAfterAdding() {
        let target = CallHistoryEventTargetSpy()
        let sut = NotifyingCallHistory(origin: TruncatingCallHistory())
        sut.updateTarget(target)
        let factory = CallHistoryRecordTestFactory()

        sut.add(factory.makeRecord(number: 1))

        #expect(target.didCallDidUpdate)
    }

    @Test func notifiesTargetAfterRemovingIndividual() {
        let target = CallHistoryEventTargetSpy()
        let sut = NotifyingCallHistory(origin: TruncatingCallHistory())
        sut.updateTarget(target)
        let record = CallHistoryRecordTestFactory().makeRecord(number: 1)

        sut.add(record)
        sut.remove(record)

        #expect(target.didUpdateCallCount == 2)
    }

    @Test func notifiesTargetAfterRemovingAll() {
        let target = CallHistoryEventTargetSpy()
        let sut = NotifyingCallHistory(origin: TruncatingCallHistory())
        sut.updateTarget(target)
        let factory = CallHistoryRecordTestFactory()

        sut.add(factory.makeRecord(number: 1))
        sut.add(factory.makeRecord(number: 2))
        sut.removeAll()

        #expect(target.didUpdateCallCount == 3)
    }
}

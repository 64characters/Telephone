//
//  PersistentCallHistoryTests.swift
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
struct PersistentCallHistoryTests {
    @Test func persistsAfterAdding() {
        let storage = MemoryPropertyListStorage()
        let record1 = makeRecord1()
        let record2 = makeRecord2()

        var sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)
        sut.add(record1)
        sut.add(record2)
        sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)

        #expect(sut.allRecords == [record1, record2])
    }

    @Test func persistsAfterRemovingIndividual() {
        let storage = MemoryPropertyListStorage()
        let record1 = makeRecord1()
        let record2 = makeRecord2()

        var sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)
        sut.add(record1)
        sut.add(record2)
        sut.remove(record1)
        sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)

        #expect(sut.allRecords == [record2])
    }

    @Test func persistsAfterRemovingAll() {
        let storage = MemoryPropertyListStorage()
        let record1 = makeRecord1()
        let record2 = makeRecord2()

        var sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)
        sut.add(record1)
        sut.add(record2)
        sut.removeAll()
        sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)

        #expect(sut.allRecords == [])
    }

    @Test func callsDeleteOnRemoveAll() {
        let storage = PropertyListStorageSpy()
        let sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)

        sut.removeAll()

        #expect(storage.didCallDelete)
    }

    @Test func doesNotCallSaveOnRemoveAll() {
        let storage = PropertyListStorageSpy()
        let sut = PersistentCallHistory(origin: TruncatingCallHistory(), storage: storage)

        sut.removeAll()

        #expect(!storage.didCallSave)
    }
}

private func makeRecord1() -> CallHistoryRecord {
    return CallHistoryRecordTestFactory().makeRecord(number: 1)
}

private func makeRecord2() -> CallHistoryRecord {
    return CallHistoryRecordTestFactory().makeRecord(number: 2)
}

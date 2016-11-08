//
//  PersistentCallHistoryTests.swift
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

final class PersistentCallHistoryTests: XCTestCase {
    private var url: URL!

    override func setUp() {
        super.setUp()
        url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("\(ProcessInfo.processInfo.globallyUniqueString)-call-history.plist")
    }

    override func tearDown() {
        super.tearDown()
        removeFile(at: url)
    }

    func testPersistsAfterAdding() {
        let record1 = makeRecord1()
        let record2 = makeRecord2()

        var sut = PersistentCallHistory(origin: TruncatingCallHistory(limit: 2), url: url)
        sut.add(record1)
        sut.add(record2)
        sut = PersistentCallHistory(origin: TruncatingCallHistory(limit: 2), url: url)

        XCTAssertEqual(sut.allRecords, [record1, record2])
    }

    func testPersistsAfterRemovingIndividual() {
        let record1 = makeRecord1()
        let record2 = makeRecord2()

        var sut = PersistentCallHistory(origin: TruncatingCallHistory(limit: 2), url: url)
        sut.add(record1)
        sut.add(record2)
        sut.remove(at: 0)
        sut = PersistentCallHistory(origin: TruncatingCallHistory(limit: 2), url: url)

        XCTAssertEqual(sut.allRecords, [record2])
    }

    func testPersistsAfterRemovingAll() {
        let record1 = makeRecord1()
        let record2 = makeRecord2()

        var sut = PersistentCallHistory(origin: TruncatingCallHistory(limit: 2), url: url)
        sut.add(record1)
        sut.add(record2)
        sut.removeAll()
        sut = PersistentCallHistory(origin: TruncatingCallHistory(limit: 2), url: url)

        XCTAssertEqual(sut.allRecords, [])
    }

    func testDiscardsOriginContentAfterCreation() {
        let origin = TruncatingCallHistory(limit: 2)
        origin.add(makeRecord1())
        origin.add(makeRecord2())

        let sut = PersistentCallHistory(origin: origin, url: url)

        XCTAssertEqual(sut.allRecords.count, 0)
    }
}

private func makeRecord1() -> CallHistoryRecord {
    return CallHistoryRecordTestFactory().makeRecord(number: 1)
}

private func makeRecord2() -> CallHistoryRecord {
    return CallHistoryRecordTestFactory().makeRecord(number: 2)
}

private func removeFile(at url: URL) {
    do {
        try FileManager.default.removeItem(at: url)
    } catch let error as NSError {
        if !(error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError) {
            XCTFail()
        }
    } catch {
        XCTFail()
    }
}

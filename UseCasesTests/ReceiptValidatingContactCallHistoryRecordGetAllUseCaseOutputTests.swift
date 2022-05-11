//
//  ReceiptValidatingContactCallHistoryRecordGetAllUseCaseOutputTests.swift
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

final class ReceiptValidatingContactCallHistoryRecordGetAllUseCaseOutputTests: XCTestCase {
    func testCallsUpdateOnOriginWithTheSameArgumentWhenReceiptIsValidOnUpdate() {
        let origin = ContactCallHistoryRecordGetAllUseCaseOutputSpy()
        let sut = ReceiptValidatingContactCallHistoryRecordGetAllUseCaseOutput(origin: origin, receipt: ValidReceipt())
        let records = makeFourRecords()

        sut.update(records: records)

        XCTAssertEqual(origin.invokedRecords, records)
    }

    func testCallsUpdateOnOriginWithFirstThreeRecordsWhenReceiptIsInvalid() {
        let origin = ContactCallHistoryRecordGetAllUseCaseOutputSpy()
        let sut = ReceiptValidatingContactCallHistoryRecordGetAllUseCaseOutput(origin: origin, receipt: InvalidReceipt())
        let records = makeFourRecords()

        sut.update(records: records)

        XCTAssertEqual(origin.invokedRecords, Array(records.prefix(3)))
    }

    func testCallsUpdateOnOriginWithFirstThreeRecordsWhenThereAreNoActivePurchases() {
        let origin = ContactCallHistoryRecordGetAllUseCaseOutputSpy()
        let sut = ReceiptValidatingContactCallHistoryRecordGetAllUseCaseOutput(origin: origin, receipt: NoActivePurchasesReceipt())
        let records = makeFourRecords()

        sut.update(records: records)

        XCTAssertEqual(origin.invokedRecords, Array(records.prefix(3)))
    }
}

private func makeFourRecords() -> [ContactCallHistoryRecord] {
    return [makeRecord(number: 1), makeRecord(number: 2), makeRecord(number: 3), makeRecord(number: 4)]
}

private func makeRecord(number: Int) -> ContactCallHistoryRecord {
    return ContactCallHistoryRecordTestFactory(factory: CallHistoryRecordTestFactory()).makeRecord(number: number)
}

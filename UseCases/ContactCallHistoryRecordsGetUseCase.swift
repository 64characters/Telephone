//
//  ContactCallHistoryRecordsGetUseCase.swift
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

public protocol ContactCallHistoryRecordsGetUseCaseOutput {
    func update(records: [ContactCallHistoryRecord])
}

public final class ContactCallHistoryRecordsGetUseCase {
    fileprivate let output: ContactCallHistoryRecordsGetUseCaseOutput

    public init(output: ContactCallHistoryRecordsGetUseCaseOutput) {
        self.output = output
    }
}

extension ContactCallHistoryRecordsGetUseCase: CallHistoryRecordsGetUseCaseOutput {
    public func update(records: [CallHistoryRecord]) {
        output.update(records: records.map(makeContactCallHistoryRecord))
    }

    private func makeContactCallHistoryRecord(record: CallHistoryRecord) -> ContactCallHistoryRecord {
        return ContactCallHistoryRecord(origin: record, contact: makeContact(address: ContactAddress(record.uri)))
    }

    private func makeContact(address: ContactAddress) -> Contact {
        return Contact(name: "any-name", address: LabeledContactAddress(origin: address, label: "any-label"))
    }
}

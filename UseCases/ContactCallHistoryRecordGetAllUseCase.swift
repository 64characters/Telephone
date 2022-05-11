//
//  ContactCallHistoryRecordGetAllUseCase.swift
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

public final class ContactCallHistoryRecordGetAllUseCase {
    private let factory: FallingBackMatchedContactFactory
    private let output: ContactCallHistoryRecordGetAllUseCaseOutput

    public init(factory: FallingBackMatchedContactFactory, output: ContactCallHistoryRecordGetAllUseCaseOutput) {
        self.factory = factory
        self.output = output
    }
}

extension ContactCallHistoryRecordGetAllUseCase: CallHistoryRecordGetAllUseCaseOutput {
    public func update(records: [CallHistoryRecord]) {
        output.update(records: records.map(makeContactCallHistoryRecord))
    }

    private func makeContactCallHistoryRecord(record: CallHistoryRecord) -> ContactCallHistoryRecord {
        return ContactCallHistoryRecord(origin: record, contact: factory.make(uri: record.uri))
    }
}

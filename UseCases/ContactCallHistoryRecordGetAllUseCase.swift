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

@ContactsActor
public final class ContactCallHistoryRecordGetAllUseCase {
    private let factory: FallingBackMatchedContactFactory
    private let output: ContactCallHistoryRecordGetAllUseCaseOutput

    public nonisolated init(factory: FallingBackMatchedContactFactory, output: ContactCallHistoryRecordGetAllUseCaseOutput) {
        self.factory = factory
        self.output = output
    }
}

extension ContactCallHistoryRecordGetAllUseCase: CallHistoryRecordGetAllUseCaseOutput {
    public func update(records: [CallHistoryRecord]) async {
        var result = [ContactCallHistoryRecord]()
        for record in records {
            result.append(await makeContactCallHistoryRecord(record: record))
        }
        await output.update(records: result)
    }

    private func makeContactCallHistoryRecord(record: CallHistoryRecord) async -> ContactCallHistoryRecord {
        return ContactCallHistoryRecord(origin: record, contact: await factory.make(uri: record.uri))
    }
}

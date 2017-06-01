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

public final class ContactCallHistoryRecordsGetUseCase {
    fileprivate let matching: ContactMatching
    fileprivate let output: ContactCallHistoryRecordsGetUseCaseOutput

    public init(matching: ContactMatching, output: ContactCallHistoryRecordsGetUseCaseOutput) {
        self.matching = matching
        self.output = output
    }
}

extension ContactCallHistoryRecordsGetUseCase: CallHistoryRecordsGetUseCaseOutput {
    public func update(records: [CallHistoryRecord]) {
        output.update(records: records.map(makeContactCallHistoryRecord))
    }

    private func makeContactCallHistoryRecord(record: CallHistoryRecord) -> ContactCallHistoryRecord {
        return ContactCallHistoryRecord(origin: record, contact: makeContact(record: record))
    }

    private func makeContact(record: CallHistoryRecord) -> MatchedContact {
        if let match = matching.match(for: record.uri) {
            return match
        } else {
            return MatchedContact(name: record.uri.displayName, address: makeAddress(for: record.uri))
        }
    }
}

private func makeAddress(for uri: URI) -> MatchedContact.Address {
    return uri.host.isEmpty ? .phone(number: uri.user, label: "") : .email(address: "\(uri.user)@\(uri.host)", label: "")
}

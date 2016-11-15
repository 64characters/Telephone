//
//  CallHistoryRecordAddUseCase.swift
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

public final class CallHistoryRecordAddUseCase {
    fileprivate let history: CallHistory
    fileprivate let record: CallHistoryRecord
    fileprivate let domain: String

    public init(history: CallHistory, record: CallHistoryRecord, domain: String) {
        self.history = history
        self.record = record
        self.domain = domain
    }
}

extension CallHistoryRecordAddUseCase: UseCase {
    public func execute() {
        history.add(recordByRemovingHostIfNeeded(from: record))
    }

    private func recordByRemovingHostIfNeeded(from record: CallHistoryRecord) -> CallHistoryRecord {
        if shouldRemoveHost(from: record) {
            return recordByRemovingHost(from: record)
        } else {
            return record
        }
    }

    private func shouldRemoveHost(from record: CallHistoryRecord) -> Bool {
        return record.host == domain || record.user.isTelephoneNumber && record.user.characters.count > 4
    }

    private func recordByRemovingHost(from record: CallHistoryRecord) -> CallHistoryRecord {
        return CallHistoryRecord(
            user: record.user, host: "", start: record.start, isIncoming: record.isIncoming, isMissed: record.isMissed
        )
    }
}

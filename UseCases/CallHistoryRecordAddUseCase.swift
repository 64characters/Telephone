//
//  CallHistoryRecordAddUseCase.swift
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

public final class CallHistoryRecordAddUseCase {
    private let history: CallHistory
    private let record: CallHistoryRecord
    private let domain: String

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
            return record.removingHost()
        } else {
            return record
        }
    }

    private func shouldRemoveHost(from record: CallHistoryRecord) -> Bool {
        return record.uri.host == domain || record.uri.user.isTelephoneNumber && record.uri.user.count > 4
    }
}

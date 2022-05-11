//
//  TruncatingCallHistory.swift
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

public final class TruncatingCallHistory {
    private var records = [CallHistoryRecord]()

    private let limit: Int

    public init(limit: Int = 100) {
        self.limit = limit
    }
}

extension TruncatingCallHistory: CallHistory {
    public var allRecords: [CallHistoryRecord] {
        return records
    }

    public func add(_ record: CallHistoryRecord) {
        records.append(record)
        if records.count > limit {
            records = [CallHistoryRecord](records.suffix(limit))
        }
    }

    public func remove(_ record: CallHistoryRecord) {
        if let index = records.firstIndex(of: record) {
            records.remove(at: index)
        }
    }

    public func removeAll() {
        records.removeAll()
    }

    public func updateTarget(_ target: CallHistoryEventTarget) {}
}

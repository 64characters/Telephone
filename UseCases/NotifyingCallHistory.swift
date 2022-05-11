//
//  NotifyingCallHistory.swift
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

public final class NotifyingCallHistory {
    private let origin: CallHistory
    private var target: CallHistoryEventTarget?

    public init(origin: CallHistory) {
        self.origin = origin
    }
}

extension NotifyingCallHistory: CallHistory {
    public var allRecords: [CallHistoryRecord] {
        return origin.allRecords
    }

    public func add(_ record: CallHistoryRecord) {
        origin.add(record)
        target?.didUpdate(self)
    }

    public func remove(_ record: CallHistoryRecord) {
        origin.remove(record)
        target?.didUpdate(self)
    }

    public func removeAll() {
        origin.removeAll()
        target?.didUpdate(self)
    }

    public func updateTarget(_ target: CallHistoryEventTarget) {
        self.target = target
    }
}

//
//  PersistentCallHistory.swift
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

public final class PersistentCallHistory {
    fileprivate let origin: CallHistory
    fileprivate let storage: PropertyListStorage

    public init(origin: CallHistory, storage: PropertyListStorage) {
        self.origin = origin
        self.storage = storage
        origin.removeAll()
        load()
    }

    private func load() {
        do {
            try storage.load().forEach({ origin.add(CallHistoryRecord(dictionary: $0)) })
        } catch {
            print("Could not read call history from file: \(error)")
        }
    }
}

extension PersistentCallHistory: CallHistory {
    public var allRecords: [CallHistoryRecord] {
        return origin.allRecords
    }

    public func add(_ record: CallHistoryRecord) {
        origin.add(record)
        save()
    }

    public func remove(_ record: CallHistoryRecord) {
        origin.remove(record)
        save()
    }

    public func removeAll() {
        origin.removeAll()
        save()
    }

    private func save() {
        do {
            try storage.save(dictionaries(from: origin.allRecords))
        } catch {
            print("Could not save call history to file: \(error)")
        }
    }
}

private extension CallHistoryRecord {
    init(dictionary: [String: Any]) {
        user = dictionary[userKey] as? String ?? ""
        host = dictionary[hostKey] as? String ?? ""
        date = dictionary[dateKey] as? Date ?? Date.distantPast
        isIncoming = dictionary[incomingKey] as? Bool ?? false
        isMissed = dictionary[missedKey] as? Bool ?? false
    }
}

private func dictionaries(from records: [CallHistoryRecord]) -> [[String: Any]] {
    return records.map {
        [
            userKey: $0.user,
            hostKey: $0.host,
            dateKey: $0.date,
            incomingKey: $0.isIncoming,
            missedKey: $0.isMissed
        ]
    }
}

private let userKey = "user"
private let hostKey = "host"
private let dateKey = "date"
private let incomingKey = "incoming"
private let missedKey = "missed"

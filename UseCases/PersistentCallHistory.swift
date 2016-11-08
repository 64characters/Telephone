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
    fileprivate let url: URL

    public init(origin: CallHistory, url: URL) {
        self.origin = origin
        self.url = url
        origin.removeAll()
        populateOriginRecordsFromURL()
    }

    private func populateOriginRecordsFromURL() {
        do {
            addToOrigin(records: try readRecords(from: url))
        } catch {
            print("Could not read call history from file: \(error)")
        }
    }

    private func addToOrigin(records: Any) {
        guard let records = records as? NSArray else { return }
        records.flatMap({ $0 as? [String: Any] }).forEach({ origin.add(CallHistoryRecord(dictionary: $0)) })
    }

    private func readRecords(from url: URL) throws -> Any {
        return try PropertyListSerialization.propertyList(from: try Data(contentsOf: url), options: [], format: nil)
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

    public func remove(at index: Int) {
        origin.remove(at: index)
        save()
    }

    public func removeAll() {
        origin.removeAll()
        save()
    }

    private func save() {
        do {
            try write(dictionaries(from: origin.allRecords), to: url)
        } catch {
            print("Could not save call history to file: \(error)")
        }
    }
}

private extension CallHistoryRecord {
    init(dictionary: [String: Any]) {
        accountID = dictionary[accountIDKey] as? String ?? ""
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
            accountIDKey: $0.accountID,
            userKey: $0.user,
            hostKey: $0.host,
            dateKey: $0.date,
            incomingKey: $0.isIncoming,
            missedKey: $0.isMissed
        ]
    }
}

private func write(_ plist: [[String: Any]], to url: URL) throws {
    try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
        .write(to: url, options: .atomic)
}

private let accountIDKey = "accountID"
private let userKey = "user"
private let hostKey = "host"
private let dateKey = "date"
private let incomingKey = "incoming"
private let missedKey = "missed"

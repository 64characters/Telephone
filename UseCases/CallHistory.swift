//
//  CallHistory.swift
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

public protocol CallHistory: AnyObject {
    var allRecords: [CallHistoryRecord] { get }
    func add(_ record: CallHistoryRecord)
    func remove(_ record: CallHistoryRecord)
    func removeAll()
    func updateTarget(_ target: CallHistoryEventTarget)
}

public extension CallHistory {
    func record(withIdentifier identifier: String) -> CallHistoryRecord? {
        return self.allRecords.first { $0.identifier == identifier }
    }
}

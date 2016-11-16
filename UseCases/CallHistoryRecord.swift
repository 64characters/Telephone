//
//  CallHistoryRecord.swift
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

import Foundation

public struct CallHistoryRecord {
    public let user: String
    public let host: String
    public let date: Date
    public let duration: Int
    public let isIncoming: Bool
    public let isMissed: Bool

    public init(user: String, host: String, date: Date, duration: Int, isIncoming: Bool, isMissed: Bool) {
        self.user = user
        self.host = host
        self.date = date
        self.duration = duration
        self.isIncoming = isIncoming
        self.isMissed = isMissed
    }

    public func removingHost() -> CallHistoryRecord {
        return CallHistoryRecord(
            user: user,
            host: "",
            date: date,
            duration: duration,
            isIncoming: isIncoming,
            isMissed: isMissed
        )
    }
}

extension CallHistoryRecord: Equatable {
    public static func ==(lhs: CallHistoryRecord, rhs: CallHistoryRecord) -> Bool {
        return lhs.user == rhs.user &&
            lhs.host == rhs.host &&
            lhs.date == rhs.date &&
            lhs.duration == rhs.duration &&
            lhs.isIncoming == rhs.isIncoming &&
            lhs.isMissed == rhs.isMissed
    }
}

extension CallHistoryRecord {
    public init(call: Call) {
        user = call.remote.user
        host = call.remote.host
        date = call.date
        duration = call.duration
        isIncoming = call.isIncoming
        isMissed = call.isMissed
    }
}

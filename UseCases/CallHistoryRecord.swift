//
//  CallHistoryRecord.swift
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

import Foundation

public struct CallHistoryRecord {
    public let identifier: String
    public let uri: URI
    public let date: Date
    public let duration: Int
    public let isIncoming: Bool
    public let isMissed: Bool

    public init(uri: URI, date: Date, duration: Int, isIncoming: Bool, isMissed: Bool) {
        identifier = "\(uri.user)@\(uri.host)|\(date.timeIntervalSinceReferenceDate)|\(duration)|\(isIncoming ? 1 : 0)"
        self.uri = uri
        self.date = date
        self.duration = duration
        self.isIncoming = isIncoming
        self.isMissed = isMissed
    }

    public func removingHost() -> CallHistoryRecord {
        return CallHistoryRecord(
            uri: URI(user: uri.user, host: "", displayName: uri.displayName),
            date: date,
            duration: duration,
            isIncoming: isIncoming,
            isMissed: isMissed
        )
    }
}

extension CallHistoryRecord: Equatable {
    public static func ==(lhs: CallHistoryRecord, rhs: CallHistoryRecord) -> Bool {
        return
            lhs.uri == rhs.uri &&
            lhs.date == rhs.date &&
            lhs.duration == rhs.duration &&
            lhs.isIncoming == rhs.isIncoming &&
            lhs.isMissed == rhs.isMissed
    }
}

extension CallHistoryRecord {
    public init(call: Call) {
        self.init(
            uri: call.remote,
            date: call.date,
            duration: call.duration,
            isIncoming: call.isIncoming,
            isMissed: call.isMissed
        )
    }
}

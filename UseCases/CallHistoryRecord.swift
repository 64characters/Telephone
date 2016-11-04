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
    public let accountID: String
    public let user: String
    public let domain: String
    public let date: Date
    public let isIncoming: Bool
    public let isMissed: Bool

    public init(accountID: String, user: String, domain: String, date: Date, isIncoming: Bool, isMissed: Bool) {
        self.accountID = accountID
        self.user = user
        self.domain = domain
        self.date = date
        self.isIncoming = isIncoming
        self.isMissed = isMissed
    }
}

extension CallHistoryRecord: Equatable {
    public static func ==(lhs: CallHistoryRecord, rhs: CallHistoryRecord) -> Bool {
        return lhs.accountID == rhs.accountID &&
            lhs.user == rhs.user &&
            lhs.domain == rhs.domain &&
            lhs.date == rhs.date &&
            lhs.isIncoming == rhs.isIncoming &&
            lhs.isMissed == rhs.isMissed
    }
}

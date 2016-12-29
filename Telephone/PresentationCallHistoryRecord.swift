//
//  PresentationCallHistoryRecord.swift
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
import UseCases

final class PresentationCallHistoryRecord: NSObject {
    let contact: PresentationContact
    let date: String
    let duration: String
    let isIncoming: Bool
    let isMissed: Bool

    init(contact: PresentationContact, date: String, duration: String, isIncoming: Bool, isMissed: Bool) {
        self.contact = contact
        self.date = date
        self.duration = duration
        self.isIncoming = isIncoming
        self.isMissed = isMissed
    }
}

extension PresentationCallHistoryRecord {
    override func isEqual(_ object: Any?) -> Bool {
        if let record = object as? PresentationCallHistoryRecord {
            return isEqual(to: record)
        } else {
            return false
        }
    }

    override var hash: Int {
        return contact.hash ^ date.hash ^ duration.hash ^ (isIncoming ? 1231 : 1237) ^ (isMissed ? 1231 : 1237)
    }

    private func isEqual(to record: PresentationCallHistoryRecord) -> Bool {
        return contact == record.contact &&
            date == record.date &&
            duration == record.duration &&
            isIncoming == record.isIncoming &&
            isMissed == record.isMissed
    }
}

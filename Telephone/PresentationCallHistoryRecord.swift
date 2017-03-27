//
//  PresentationCallHistoryRecord.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

import Cocoa
import UseCases

final class PresentationCallHistoryRecord: NSObject {
    let contact: PresentationContact
    let date: String
    let duration: String
    let isIncoming: Bool

    init(contact: PresentationContact, date: String, duration: String, isIncoming: Bool) {
        self.contact = contact
        self.date = date
        self.duration = duration
        self.isIncoming = isIncoming
    }
}

extension PresentationCallHistoryRecord {
    override func isEqual(_ object: Any?) -> Bool {
        guard let record = object as? PresentationCallHistoryRecord else { return false }
        return isEqual(to: record)
    }

    override var hash: Int {
        return contact.hash ^ date.hash ^ duration.hash ^ (isIncoming ? 1231 : 1237)
    }

    private func isEqual(to record: PresentationCallHistoryRecord) -> Bool {
        return contact == record.contact &&
            date == record.date &&
            duration == record.duration &&
            isIncoming == record.isIncoming
    }
}

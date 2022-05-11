//
//  PresentationCallHistoryRecord.swift
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

import Cocoa
import UseCases

final class PresentationCallHistoryRecord: NSObject {
    let identifier: String
    @objc let contact: PresentationContact
    @objc let date: String
    @objc let duration: String
    @objc let isIncoming: Bool

    init(identifier: String, contact: PresentationContact, date: String, duration: String, isIncoming: Bool) {
        self.identifier = identifier
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
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(contact)
        hasher.combine(date)
        hasher.combine(duration)
        hasher.combine(isIncoming)
        return hasher.finalize()
    }

    private func isEqual(to record: PresentationCallHistoryRecord) -> Bool {
        return
            identifier == record.identifier &&
            contact == record.contact &&
            date == record.date &&
            duration == record.duration &&
            isIncoming == record.isIncoming
    }
}

extension PresentationCallHistoryRecord: NSPasteboardWriting {
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.string]
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        return contact.address
    }
}

extension PresentationCallHistoryRecord {
    var name: String {
        return contact.title.isEmpty ? date : "\(contact.title), \(date)"
    }
}

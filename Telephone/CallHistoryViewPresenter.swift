//
//  CallHistoryViewPresenter.swift
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

final class CallHistoryViewPresenter {
    private let view: CallHistoryView
    private let dateFormatter: DateFormatter
    private let durationFormatter: DateComponentsFormatter

    init(view: CallHistoryView, dateFormatter: DateFormatter, durationFormatter: DateComponentsFormatter) {
        self.view = view
        self.dateFormatter = dateFormatter
        self.durationFormatter = durationFormatter
    }
}

extension CallHistoryViewPresenter: ContactCallHistoryRecordGetAllUseCaseOutput {
    func update(records: [ContactCallHistoryRecord]) {
        view.show(records.map(makeRecord))
    }

    private func makeRecord(from record: ContactCallHistoryRecord) -> PresentationCallHistoryRecord {
        return PresentationCallHistoryRecord(
            identifier: record.origin.identifier,
            contact: PresentationContact(contact: record.contact, color: contactColor(for: record)),
            date: dateFormatter.string(from: record.origin.date),
            duration: durationFormatter.string(from: TimeInterval(record.origin.duration)) ?? "",
            isIncoming: record.origin.isIncoming
        )
    }
}

private func contactColor(for record: ContactCallHistoryRecord) -> NSColor {
    return record.origin.isMissed ? NSColor.systemRed : NSColor.controlTextColor
}

//
//  CallHistoryViewPresenter.swift
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

import UseCases

final class CallHistoryViewPresenter {
    fileprivate let view: CallHistoryView
    fileprivate let dateFormatter: DateFormatter
    fileprivate let durationFormatter: DateComponentsFormatter

    init(view: CallHistoryView, dateFormatter: DateFormatter, durationFormatter: DateComponentsFormatter) {
        self.view = view
        self.dateFormatter = dateFormatter
        self.durationFormatter = durationFormatter
    }
}

extension CallHistoryViewPresenter: ContactCallHistoryRecordsGetUseCaseOutput {
    func update(records: [ContactCallHistoryRecord]) {
        view.show(records.map(makeRecord))
    }

    private func makeRecord(from record: ContactCallHistoryRecord) -> PresentationCallHistoryRecord {
        return PresentationCallHistoryRecord(
            contact: PresentationContact(record.contact),
            date: dateFormatter.string(from: record.origin.date),
            duration: durationFormatter.string(from: TimeInterval(record.origin.duration)) ?? "",
            isIncoming: record.origin.isIncoming,
            isMissed: record.origin.isMissed
        )
    }
}

//
//  CallHistoryViewEventTargetFactory.swift
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

final class CallHistoryViewEventTargetFactory: NSObject {
    private let histories: CallHistories
    private let dateFormatter: DateFormatter
    private let durationFormatter: DateComponentsFormatter

    init(histories: CallHistories, dateFormatter: DateFormatter, durationFormatter: DateComponentsFormatter) {
        self.histories = histories
        self.dateFormatter = dateFormatter
        self.durationFormatter = durationFormatter
    }

    func make(for account: Account, view: CallHistoryView) -> CallHistoryViewEventTarget {
        return CallHistoryViewEventTarget(
            recordsGet: CallHistoryRecordsGetUseCase(
                history: histories.history(for: account),
                output: ContactCallHistoryRecordsGetUseCase(
                    output: CallHistoryViewPresenter(
                        view: view, dateFormatter: dateFormatter, durationFormatter: durationFormatter
                    )
                )
            )
        )
    }
}

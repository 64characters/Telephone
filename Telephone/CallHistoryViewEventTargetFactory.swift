//
//  CallHistoryViewEventTargetFactory.swift
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

import UseCases

final class CallHistoryViewEventTargetFactory: NSObject {
    private let histories: CallHistories
    private let matching: ContactMatching
    private let dateFormatter: DateFormatter
    private let durationFormatter: DateComponentsFormatter
    private let background: ExecutionQueue
    private let main: ExecutionQueue

    init(
        histories: CallHistories,
        matching: ContactMatching,
        dateFormatter: DateFormatter,
        durationFormatter: DateComponentsFormatter,
        background: ExecutionQueue,
        main: ExecutionQueue
        ) {
        self.histories = histories
        self.matching = matching
        self.dateFormatter = dateFormatter
        self.durationFormatter = durationFormatter
        self.background = background
        self.main = main
    }

    func make(account: Account, view: CallHistoryView) -> CallHistoryViewEventTarget {
        let history = histories.history(withUUID: account.uuid)
        let result = CallHistoryViewEventTarget(
            recordsGet: CallHistoryRecordsGetUseCase(
                history: history,
                output: EnqueuingCallHistoryRecordsGetUseCaseOutput(
                    origin: ContactCallHistoryRecordsGetUseCase(
                        matching: matching,
                        output: EnqueuingContactCallHistoryRecordsGetUseCaseOutput(
                            origin: CallHistoryViewPresenter(
                                view: view, dateFormatter: dateFormatter, durationFormatter: durationFormatter
                            ),
                            queue: main
                        )
                    ),
                    queue: background
                )
            ),
            recordRemove: DefaultCallHistoryRecordRemoveUseCaseFactory(history: history),
            callMake: DefaultCallHistoryCallMakeUseCaseFactory(account: account, history: history)
        )
        history.updateTarget(result)
        return result
    }
}

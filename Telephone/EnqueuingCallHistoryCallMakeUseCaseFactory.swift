//
//  EnqueuingCallHistoryCallMakeUseCaseFactory.swift
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

import UseCases

final class EnqueuingCallHistoryCallMakeUseCaseFactory {
    private let account: Account
    private let history: CallHistory
    private let factory: FallingBackMatchedContactFactory
    private let accountQueue: ExecutionQueue
    private let historyQueue: ExecutionQueue

    init(account: Account, history: CallHistory, factory: FallingBackMatchedContactFactory, accountQueue: ExecutionQueue, historyQueue: ExecutionQueue) {
        self.account = account
        self.history = history
        self.factory = factory
        self.historyQueue = historyQueue
        self.accountQueue = accountQueue
    }
}

extension EnqueuingCallHistoryCallMakeUseCaseFactory: CallHistoryCallMakeUseCaseFactory {
    func make(identifier: String) -> UseCase {
        return EnqueuingUseCase(
            origin: CallHistoryRecordGetUseCase(
                identifier: identifier,
                history: history,
                output: ContactCallHistoryRecordGetUseCase(
                    factory: factory,
                    output: EnqueuingContactCallHistoryRecordGetUseCaseOutput(
                        origin: CallHistoryCallMakeUseCase(account: account), queue: accountQueue
                    )
                )
            ),
            queue: historyQueue
        )
    }
}

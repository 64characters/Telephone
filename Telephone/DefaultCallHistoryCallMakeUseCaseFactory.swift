//
//  CallHistoryCallMakeUseCaseFactory.swift
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

final class DefaultCallHistoryCallMakeUseCaseFactory {
    private let account: Account
    private let history: CallHistory
    private let factory: FallingBackMatchedContactFactory

    init(account: Account, history: CallHistory, factory: FallingBackMatchedContactFactory) {
        self.account = account
        self.history = history
        self.factory = factory
    }
}

extension DefaultCallHistoryCallMakeUseCaseFactory: CallHistoryCallMakeUseCaseFactory {
    func make(identifier: String) -> UseCase {
        return CallHistoryRecordGetUseCase(
            identifier: identifier,
            history: history,
            output: ContactCallHistoryRecordGetUseCase(
                factory: factory, output: CallHistoryCallMakeUseCase(account: account)
            )
        )
    }
}

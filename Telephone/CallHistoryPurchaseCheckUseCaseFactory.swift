//
//  CallHistoryPurchaseCheckUseCaseFactory.swift
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

final class CallHistoryPurchaseCheckUseCaseFactory {
    private let histories: CallHistories
    private let receipt: Receipt
    private let background: ExecutionQueue
    private let main: ExecutionQueue

    init(histories: CallHistories, receipt: Receipt, background: ExecutionQueue, main: ExecutionQueue) {
        self.histories = histories
        self.receipt = receipt
        self.background = background
        self.main = main
    }

    func make(account: Account, output: RecordCountingPurchaseCheckUseCaseOutput) -> UseCase {
        return EnqueuingUseCase(
            origin: CallHistoryRecordGetAllUseCase(
                history: histories.history(withUUID: account.uuid),
                output: EnqueuingCallHistoryRecordGetAllUseCaseOutput(
                    origin: RecordCountingPurchaseCheckUseCase(
                        factory: PurchaseCheckUseCaseFactory(receipt: receipt), output: output
                    ),
                    queue: main
                )
            ),
            queue: background
        )
    }
}

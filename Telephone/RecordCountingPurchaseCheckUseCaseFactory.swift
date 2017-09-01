//
//  RecordCountingPurchaseCheckUseCaseFactory.swift
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

final class RecordCountingPurchaseCheckUseCaseFactory {
    private let histories: CallHistories
    private let receipt: Receipt

    init(histories: CallHistories, receipt: Receipt) {
        self.histories = histories
        self.receipt = receipt
    }

    func make(account: Account, output: RecordCountingPurchaseCheckUseCaseOutput) -> UseCase {
        return CallHistoryRecordGetAllUseCase(
            history: histories.history(withUUID: account.uuid),
            output: RecordCountingPurchaseCheckUseCase(
                factory: PurchaseCheckUseCaseFactory(receipt: receipt), output: output
            )
        )
    }
}

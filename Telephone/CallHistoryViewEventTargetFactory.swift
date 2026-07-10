//
//  CallHistoryViewEventTargetFactory.swift
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

@MainActor
final class CallHistoryViewEventTargetFactory {
    private let histories: CallHistories
    private let index: ContactMatchingIndex
    private let settings: ContactMatchingSettings
    private let receipt: Receipt
    private let dateFormatter: DateFormatter
    private let durationFormatter: DateComponentsFormatter
    private let storeEventTargets: StoreEventTargets
    private let dayChangeEventTargets: DayChangeEventTargets

    init(
        histories: CallHistories,
        index: ContactMatchingIndex,
        settings: ContactMatchingSettings,
        receipt: Receipt,
        dateFormatter: DateFormatter,
        durationFormatter: DateComponentsFormatter,
        storeEventTargets: StoreEventTargets,
        dayChangeEventTargets: DayChangeEventTargets,
        ) {
        self.histories = histories
        self.index = index
        self.settings = settings
        self.receipt = receipt
        self.dateFormatter = dateFormatter
        self.durationFormatter = durationFormatter
        self.storeEventTargets = storeEventTargets
        self.dayChangeEventTargets = dayChangeEventTargets
    }

    func make(account: Account, view: CallHistoryView, purchaseCheck: UseCase) async -> CallHistoryViewEventTarget {
        let history = await histories.history(withUUID: account.uuid)
        let factory = FallingBackMatchedContactFactory(
            matching: IndexedContactMatching(
                index: index,
                significantPhoneNumberLength: await settings.significantPhoneNumberLength,
                domain: account.domain
            )
        )
        let result = CallHistoryViewEventTarget(
            recordsGet: CallHistoryRecordGetAllUseCase(
                history: history,
                output: ContactCallHistoryRecordGetAllUseCase(
                    factory: factory,
                    output: ReceiptValidatingContactCallHistoryRecordGetAllUseCaseOutput(
                        origin: CallHistoryViewPresenter(
                            view: view, dateFormatter: dateFormatter, durationFormatter: durationFormatter
                        ),
                        receipt: receipt
                    )
                )
            ),
            purchaseCheck: purchaseCheck,
            recordRemoveAll: CallHistoryRecordRemoveAllUseCase(history: history),
            recordRemove: DefaultCallHistoryRecordRemoveUseCaseFactory(history: history),
            callMake: DefaultCallHistoryCallMakeUseCaseFactory(account: account, history: history, factory: factory)
        )
        await history.updateTarget(WeakCallHistoryEventTarget(origin: result))
        storeEventTargets.add(WeakStoreEventTarget(origin: result))
        dayChangeEventTargets.add(WeakDayChangeEventTarget(origin: result))
        return result
    }
}

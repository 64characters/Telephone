//
//  CallHistoryViewEventTarget.swift
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

final class CallHistoryViewEventTarget: NSObject {
    private let recordsGet: UseCase
    private let purchaseCheck: UseCase
    private let recordRemoveAll: UseCase
    private let recordRemove: CallHistoryRecordRemoveUseCaseFactory
    private let callMake: CallHistoryCallMakeUseCaseFactory

    init(recordsGet: UseCase,
         purchaseCheck: UseCase,
         recordRemoveAll: UseCase,
         recordRemove: CallHistoryRecordRemoveUseCaseFactory,
         callMake: CallHistoryCallMakeUseCaseFactory) {
        self.recordsGet = recordsGet
        self.purchaseCheck = purchaseCheck
        self.recordRemoveAll = recordRemoveAll
        self.recordRemove = recordRemove
        self.callMake = callMake
    }

    func shouldReloadData() {
        executeRecordGetAndPurchaseCheck()
    }

    func shouldRemoveAllRecords() {
        recordRemoveAll.execute()
    }

    func didPickRecord(withIdentifier identifier: String) {
        callMake.make(identifier: identifier).execute()
    }

    func shouldRemoveRecord(withIdentifier identifier: String) {
        recordRemove.make(identifier: identifier).execute()
    }

    private func executeRecordGetAndPurchaseCheck() {
        recordsGet.execute()
        purchaseCheck.execute()
    }
}

extension CallHistoryViewEventTarget: CallHistoryEventTarget {
    func didUpdate(_ history: CallHistory) {
        executeRecordGetAndPurchaseCheck()
    }
}

extension CallHistoryViewEventTarget: StoreEventTarget {
    func didPurchase() {
        executeRecordGetAndPurchaseCheck()
    }

    func didRestorePurchases() {
        executeRecordGetAndPurchaseCheck()
    }

    func didStartPurchasingProduct(withIdentifier identifier: String) {}
    func didFailPurchasing(error: String) {}
    func didCancelPurchasing() {}
    func didFailRestoringPurchases(error: String) {}
    func didCancelRestoringPurchases() {}
}

extension CallHistoryViewEventTarget: DayChangeEventTarget {
    func dayDidChange() {
        executeRecordGetAndPurchaseCheck()
    }
}

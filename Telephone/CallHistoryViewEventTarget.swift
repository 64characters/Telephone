//
//  CallHistoryViewEventTarget.swift
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

final class CallHistoryViewEventTarget: NSObject {
    fileprivate let recordsGet: UseCase
    private let recordRemove: CallHistoryRecordRemoveUseCaseFactory
    private let callMake: CallHistoryCallMakeUseCaseFactory

    init(recordsGet: UseCase, recordRemove: CallHistoryRecordRemoveUseCaseFactory, callMake: CallHistoryCallMakeUseCaseFactory) {
        self.recordsGet = recordsGet
        self.recordRemove = recordRemove
        self.callMake = callMake
    }

    func shouldReloadData() {
        recordsGet.execute()
    }

    func didPickRecord(withIdentifier identifier: String) {
        callMake.make(identifier: identifier).execute()
    }

    func shouldRemoveRecord(withIdentifier identifier: String) {
        recordRemove.make(identifier: identifier).execute()
    }
}

extension CallHistoryViewEventTarget: CallHistoryEventTarget {
    func didUpdate(_ history: CallHistory) {
        recordsGet.execute()
    }
}

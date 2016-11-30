//
//  CallHistoryCallEventTarget.swift
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

public final class CallHistoryCallEventTarget {
    fileprivate let histories: CallHistories

    public init(histories: CallHistories) {
        self.histories = histories
    }
}

extension CallHistoryCallEventTarget: CallEventTarget {
    public func callDidDisconnect(_ call: Call) {
        histories.history(forAccountWithID: call.account.uuid).add(CallHistoryRecord(call: call))
    }
}

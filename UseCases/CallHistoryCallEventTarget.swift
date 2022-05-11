//
//  CallHistoryCallEventTarget.swift
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

public final class CallHistoryCallEventTarget {
    private let histories: CallHistories
    private let factory: CallHistoryRecordAddUseCaseFactory

    public init(histories: CallHistories, factory: CallHistoryRecordAddUseCaseFactory) {
        self.histories = histories
        self.factory = factory
    }
}

extension CallHistoryCallEventTarget: CallEventTarget {
    public func didDisconnect(_ call: Call) {
        factory.make(
            history: histories.history(withUUID: call.account.uuid),
            record: CallHistoryRecord(call: call),
            domain: call.account.domain
        ).execute()
    }

    public func didMake(_ call: Call) {}
    public func didReceive(_ call: Call) {}
    public func isConnecting(_ call: Call) {}
}

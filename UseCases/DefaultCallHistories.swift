//
//  DefaultCallHistories.swift
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

public final class DefaultCallHistories {
    fileprivate var histories: [String: CallHistory] = [:]
    fileprivate let factory: CallHistoryFactory

    public init(factory: CallHistoryFactory) {
        self.factory = factory
    }
}

extension DefaultCallHistories: CallHistories {
    public func history(for account: Account) -> CallHistory {
        if let history = histories[account.uuid] {
            return history
        } else {
            return makeHistory(uuid: account.uuid)
        }
    }

    private func makeHistory(uuid: String) -> CallHistory {
        let result = factory.make(uuid: uuid)
        histories[uuid] = result
        return result
    }
}

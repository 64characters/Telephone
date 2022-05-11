//
//  DefaultCallHistories.swift
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

public final class DefaultCallHistories {
    private var histories: [String: CallHistory] = [:]
    private let factory: CallHistoryFactory

    var count: Int { return histories.count }

    public init(factory: CallHistoryFactory) {
        self.factory = factory
    }
}

extension DefaultCallHistories: CallHistories {
    public func history(withUUID uuid: String) -> CallHistory {
        if let history = histories[uuid] {
            return history
        } else {
            return makeHistory(uuid: uuid)
        }
    }

    public func remove(withUUID uuid: String) {
        histories.removeValue(forKey: uuid)
    }

    private func makeHistory(uuid: String) -> CallHistory {
        let result = factory.make(uuid: uuid)
        histories[uuid] = result
        return result
    }
}

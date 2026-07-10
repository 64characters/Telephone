//
//  CallHistoriesSpy.swift
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

@CallHistoryActor
public final class CallHistoriesSpy  {
    private let histories: [String: CallHistory]
    private let removeCallback: (String) -> Void

    public init(histories: [String: CallHistory], removeCallback: @escaping (String) -> Void) {
        self.histories = histories
        self.removeCallback = removeCallback
    }
}

extension CallHistoriesSpy: CallHistories {
    public func history(withUUID uuid: String) -> CallHistory {
        return histories[uuid]!
    }

    public func remove(withUUID uuid: String) {
        removeCallback(uuid)
    }
}

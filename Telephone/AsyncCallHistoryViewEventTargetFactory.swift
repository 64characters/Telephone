//
//  AsyncCallHistoryViewEventTargetFactory.swift
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

final class AsyncCallHistoryViewEventTargetFactory: NSObject {
    private let origin: CallHistoryViewEventTargetFactory
    private let background: ExecutionQueue
    private let main: ExecutionQueue

    init(origin: CallHistoryViewEventTargetFactory, background: ExecutionQueue, main: ExecutionQueue) {
        self.origin = origin
        self.background = background
        self.main = main
    }

    @objc func make(account: Account, view: CallHistoryView, purchaseCheck: UseCase, completion: @escaping (CallHistoryViewEventTarget) -> Void) {
        background.add {
            let result = self.origin.make(account: account, view: view, purchaseCheck: purchaseCheck)
            self.main.add {
                completion(result)
            }
        }
    }
}

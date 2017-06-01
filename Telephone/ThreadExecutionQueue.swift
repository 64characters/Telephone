//
//  ThreadExecutionQueue.swift
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

import Foundation
import UseCases

final class ThreadExecutionQueue: NSObject {
    fileprivate let thread: Thread

    init(thread: Thread) {
        self.thread = thread
    }
}

extension ThreadExecutionQueue: ExecutionQueue {
    func add(_ block: @escaping () -> Void) {
        perform(#selector(run), on: thread, with: block, waitUntilDone: false)
    }

    @objc private func run(_ block: Any) {  // RunLoop.run() crashes if block type is () -> Void, so had to use Any instead.
        if let block = block as? () -> Void {
            block()
        }
    }
}

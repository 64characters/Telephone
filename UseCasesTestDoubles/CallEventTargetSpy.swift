//
//  CallEventTargetSpy.swift
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

public final class CallEventTargetSpy {
    public private(set) var didCallDidMake = false
    public private(set) var didCallDidReceive = false
    public private(set) var didCallIsConnecting = false
    public private(set) var didCallDidDisconnect = false
    public private(set) var invokedCall: Call?

    public init() {}
}

extension CallEventTargetSpy: CallEventTarget {
    public func didMake(_ call: Call) {
        didCallDidMake = true
        invokedCall = call
    }

    public func didReceive(_ call: Call) {
        didCallDidReceive = true
        invokedCall = call
    }

    public func isConnecting(_ call: Call) {
        didCallIsConnecting = true
        invokedCall = call
    }

    public func didDisconnect(_ call: Call) {
        didCallDidDisconnect = true
        invokedCall = call
    }
}

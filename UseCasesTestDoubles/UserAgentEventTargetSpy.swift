//
//  UserAgentEventTargetSpy.swift
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

public final class UserAgentEventTargetSpy {
    public private(set) var didCallDidFinishStarting = false
    public private(set) var didCallDidFinishStopping = false
    public private(set) var didCallDidDetectNAT = false
    public private(set) var didCallDidMakeCall = false
    public private(set) var didCallDidReceiveCall = false
    public private(set) var lastPassedAgent: UserAgent?

    public init() {}
}

extension UserAgentEventTargetSpy: UserAgentEventTarget {
    public func didFinishStarting(_ agent: UserAgent) {
        didCallDidFinishStarting = true
        lastPassedAgent = agent
    }

    public func didFinishStopping(_ agent: UserAgent) {
        didCallDidFinishStopping = true
        lastPassedAgent = agent
    }

    public func didDetectNAT(_ agent: UserAgent) {
        didCallDidDetectNAT = true
        lastPassedAgent = agent
    }

    public func didMakeCall(_ agent: UserAgent) {
        didCallDidMakeCall = true
        lastPassedAgent = agent
    }

    public func didReceiveCall(_ agent: UserAgent) {
        didCallDidReceiveCall = true
        lastPassedAgent = agent
    }
}

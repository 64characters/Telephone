//
//  UserAgentEventTargets.swift
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

public final class UserAgentEventTargets {
    fileprivate let targets: [UserAgentEventTarget]

    public init(targets: [UserAgentEventTarget]) {
        self.targets = targets
    }
}

extension UserAgentEventTargets: UserAgentEventTarget {
    public func didFinishStarting(_ agent: UserAgent) {
        targets.forEach { $0.didFinishStarting(agent) }
    }

    public func didFinishStopping(_ agent: UserAgent) {
        targets.forEach { $0.didFinishStopping(agent) }
    }

    public func didDetectNAT(_ agent: UserAgent) {
        targets.forEach { $0.didDetectNAT(agent) }
    }

    public func didMakeCall(_ agent: UserAgent) {
        targets.forEach { $0.didMakeCall(agent) }
    }

    public func didReceiveCall(_ agent: UserAgent) {
        targets.forEach { $0.didReceiveCall(agent) }
    }
}

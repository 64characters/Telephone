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
    public func userAgentDidFinishStarting(_ userAgent: UserAgent) {
        targets.forEach { $0.userAgentDidFinishStarting(userAgent) }
    }

    public func userAgentDidFinishStopping(_ userAgent: UserAgent) {
        targets.forEach { $0.userAgentDidFinishStopping(userAgent) }
    }

    public func userAgentDidDetectNAT(_ userAgent: UserAgent) {
        targets.forEach { $0.userAgentDidDetectNAT(userAgent) }
    }

    public func userAgentDidMakeCall(_ userAgent: UserAgent) {
        targets.forEach { $0.userAgentDidMakeCall(userAgent) }
    }

    public func userAgentDidReceiveCall(_ userAgent: UserAgent) {
        targets.forEach { $0.userAgentDidReceiveCall(userAgent) }
    }
}

//
//  UserAgentEventTargetComposite.swift
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

public class UserAgentEventTargetComposite {
    public let targets: [UserAgentEventTarget]

    public init(targets: [UserAgentEventTarget]) {
        self.targets = targets
    }
}

extension UserAgentEventTargetComposite: UserAgentEventTarget {
    public func userAgentDidFinishStarting(userAgent: UserAgent) {
        onEachTarget { $0.userAgentDidFinishStarting(userAgent) }
    }

    public func userAgentDidFinishStopping(userAgent: UserAgent) {
        onEachTarget { $0.userAgentDidFinishStopping(userAgent) }
    }

    public func userAgentDidDetectNAT(userAgent: UserAgent) {
        onEachTarget { $0.userAgentDidDetectNAT(userAgent) }
    }

    private func onEachTarget(function: UserAgentEventTarget -> Void) {
        for target in targets { function(target) }
    }
}

//
//  UserAgentObserverComposite.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov
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

public class UserAgentObserverComposite {
    public let observers: [UserAgentObserver]

    public init(observers: [UserAgentObserver]) {
        self.observers = observers
    }
}

extension UserAgentObserverComposite: UserAgentObserver {
    public func userAgentDidFinishStarting(userAgent: UserAgent) {
        onEachObserver { $0.userAgentDidFinishStarting(userAgent) }
    }

    public func userAgentDidFinishStopping(userAgent: UserAgent) {
        onEachObserver { $0.userAgentDidFinishStopping(userAgent) }
    }

    public func userAgentDidDetectNAT(userAgent: UserAgent) {
        onEachObserver { $0.userAgentDidDetectNAT(userAgent) }
    }

    private func onEachObserver(function: UserAgentObserver -> Void) {
        for observer in observers { function(observer) }
    }
}

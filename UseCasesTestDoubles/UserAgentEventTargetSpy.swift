//
//  UserAgentEventTargetSpy.swift
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

import UseCases

public final class UserAgentEventTargetSpy {
    public fileprivate(set) var didCallUserAgentDidFinishStarting = false
    public fileprivate(set) var didCallUserAgentDidFinishStopping = false
    public fileprivate(set) var didCallUserAgentDidDetectNAT = false
    public fileprivate(set) var didCallDidMakeCall = false
    public fileprivate(set) var didCallDidReceiveCall = false
    public fileprivate(set) var lastPassedUserAgent: UserAgent?

    public init() {}
}

extension UserAgentEventTargetSpy: UserAgentEventTarget {
    public func userAgentDidFinishStarting(_ userAgent: UserAgent) {
        didCallUserAgentDidFinishStarting = true
        lastPassedUserAgent = userAgent
    }

    public func userAgentDidFinishStopping(_ userAgent: UserAgent) {
        didCallUserAgentDidFinishStopping = true
        lastPassedUserAgent = userAgent
    }

    public func userAgentDidDetectNAT(_ userAgent: UserAgent) {
        didCallUserAgentDidDetectNAT = true
        lastPassedUserAgent = userAgent
    }

    public func userAgentDidMakeCall(_ userAgent: UserAgent) {
        didCallDidMakeCall = true
        lastPassedUserAgent = userAgent
    }

    public func userAgentDidReceiveCall(_ userAgent: UserAgent) {
        didCallDidReceiveCall = true
        lastPassedUserAgent = userAgent
    }
}

//
//  UserAgentNotificationsToEventTargetAdapter.swift
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

final class UserAgentNotificationsToEventTargetAdapter {
    fileprivate let target: UserAgentEventTarget
    fileprivate let userAgent: UserAgent

    init(target: UserAgentEventTarget, userAgent: UserAgent) {
        self.target = target
        self.userAgent = userAgent
        subscribe()
    }

    deinit {
        unsubscribe()
    }

    fileprivate func subscribe() {
        let nc = NotificationCenter.default
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidFinishStarting),
            name: NSNotification.Name.AKSIPUserAgentDidFinishStarting,
            object: userAgent
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidFinishStopping),
            name: NSNotification.Name.AKSIPUserAgentDidFinishStopping,
            object: userAgent
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidDetectNAT),
            name: NSNotification.Name.AKSIPUserAgentDidDetectNAT,
            object: userAgent
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidMakeCall),
            name: NSNotification.Name.AKSIPCallCalling,
            object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidReceiveCall),
            name: NSNotification.Name.AKSIPCallIncoming,
            object: nil
        )
    }

    fileprivate func unsubscribe() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name.AKSIPUserAgentDidFinishStarting, object: userAgent)
        nc.removeObserver(self, name: NSNotification.Name.AKSIPUserAgentDidFinishStopping, object: userAgent)
        nc.removeObserver(self, name: NSNotification.Name.AKSIPUserAgentDidDetectNAT, object: userAgent)
    }

    dynamic fileprivate func SIPUserAgentDidFinishStarting(_ notification: Notification) {
        assert(userAgent === notification.object as! UserAgent)
        target.userAgentDidFinishStarting(userAgent)
    }

    dynamic fileprivate func SIPUserAgentDidFinishStopping(_ notification: Notification) {
        assert(userAgent === notification.object as! UserAgent)
        target.userAgentDidFinishStopping(userAgent)
    }

    dynamic fileprivate func SIPUserAgentDidDetectNAT(_ notification: Notification) {
        assert(userAgent === notification.object as! UserAgent)
        target.userAgentDidDetectNAT(userAgent)
    }

    dynamic fileprivate func SIPUserAgentDidMakeCall(_ notification: Notification) {
        target.userAgentDidMakeCall(userAgent)
    }

    dynamic fileprivate func SIPUserAgentDidReceiveCall(_ notification: Notification) {
        target.userAgentDidReceiveCall(userAgent)
    }
}

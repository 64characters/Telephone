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

class UserAgentNotificationsToEventTargetAdapter {
    private let target: UserAgentEventTarget
    private let userAgent: UserAgent

    init(target: UserAgentEventTarget, userAgent: UserAgent) {
        self.target = target
        self.userAgent = userAgent
        subscribe()
    }

    deinit {
        unsubscribe()
    }

    private func subscribe() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidFinishStarting),
            name: AKSIPUserAgentDidFinishStartingNotification,
            object: userAgent
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidFinishStopping),
            name: AKSIPUserAgentDidFinishStoppingNotification,
            object: userAgent
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidDetectNAT),
            name: AKSIPUserAgentDidDetectNATNotification,
            object: userAgent
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidMakeCall),
            name: AKSIPCallCallingNotification,
            object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(SIPUserAgentDidReceiveCall),
            name: AKSIPCallIncomingNotification,
            object: nil
        )
    }

    private func unsubscribe() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: AKSIPUserAgentDidFinishStartingNotification, object: userAgent)
        nc.removeObserver(self, name: AKSIPUserAgentDidFinishStoppingNotification, object: userAgent)
        nc.removeObserver(self, name: AKSIPUserAgentDidDetectNATNotification, object: userAgent)
    }

    dynamic private func SIPUserAgentDidFinishStarting(notification: NSNotification) {
        assert(userAgent === notification.object)
        target.userAgentDidFinishStarting(userAgent)
    }

    dynamic private func SIPUserAgentDidFinishStopping(notification: NSNotification) {
        assert(userAgent === notification.object)
        target.userAgentDidFinishStopping(userAgent)
    }

    dynamic private func SIPUserAgentDidDetectNAT(notification: NSNotification) {
        assert(userAgent === notification.object)
        target.userAgentDidDetectNAT(userAgent)
    }

    dynamic private func SIPUserAgentDidMakeCall(notification: NSNotification) {
        target.userAgentDidMakeCall(userAgent)
    }

    dynamic private func SIPUserAgentDidReceiveCall(notification: NSNotification) {
        target.userAgentDidReceiveCall(userAgent)
    }
}

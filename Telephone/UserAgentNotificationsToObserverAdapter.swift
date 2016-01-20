//
//  UserAgentNotificationsToObserverAdapter.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

class UserAgentNotificationsToObserverAdapter {
    let observer: UserAgentObserver
    let userAgent: UserAgent

    init(observer: UserAgentObserver, userAgent: UserAgent) {
        self.observer = observer
        self.userAgent = userAgent
        subscribe()
    }

    deinit {
        unsubscribe()
    }

    private func subscribe() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "SIPUserAgentDidFinishStarting:", name: AKSIPUserAgentDidFinishStartingNotification, object: userAgent)
        nc.addObserver(self, selector: "SIPUserAgentDidFinishStopping:", name: AKSIPUserAgentDidFinishStoppingNotification, object: userAgent)
        nc.addObserver(self, selector: "SIPUserAgentDidDetectNAT:", name: AKSIPUserAgentDidDetectNATNotification, object: userAgent)
    }

    private func unsubscribe() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: AKSIPUserAgentDidFinishStartingNotification, object: userAgent)
        nc.removeObserver(self, name: AKSIPUserAgentDidFinishStoppingNotification, object: userAgent)
        nc.removeObserver(self, name: AKSIPUserAgentDidDetectNATNotification, object: userAgent)
    }

    dynamic private func SIPUserAgentDidFinishStarting(notification: NSNotification) {
        assert(userAgent === notification.object)
        observer.userAgentDidFinishStarting(userAgent)
    }

    dynamic private func SIPUserAgentDidFinishStopping(notification: NSNotification) {
        assert(userAgent === notification.object)
        observer.userAgentDidFinishStopping(userAgent)
    }

    dynamic private func SIPUserAgentDidDetectNAT(notification: NSNotification) {
        assert(userAgent === notification.object)
        observer.userAgentDidDetectNAT(userAgent)
    }
}

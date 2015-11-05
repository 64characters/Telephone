//
//  UserAgentNotificationsToObserverAdapter.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

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

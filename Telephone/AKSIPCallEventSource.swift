//
//  AKSIPCallEventSource.swift
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

import Foundation
import UseCases

final class AKSIPCallEventSource {
    private let center: NotificationCenter
    private let target: CallEventTarget

    init(center: NotificationCenter, target: CallEventTarget) {
        self.center = center
        self.target = target
        center.addObserver(self, selector: #selector(didMake), name: .AKSIPCallCalling, object: nil)
        center.addObserver(self, selector: #selector(didReceive), name: .AKSIPCallIncoming, object: nil)
        center.addObserver(self, selector: #selector(isConnecting), name: .AKSIPCallConnecting, object: nil)
        center.addObserver(self, selector: #selector(didDisconnect), name: .AKSIPCallDidDisconnect, object: nil)
    }

    deinit {
        center.removeObserver(self)
    }

    @objc private func didMake(_ notification: Notification) {
        target.didMake(notification.object as! Call)
    }

    @objc private func didReceive(_ notification: Notification) {
        target.didReceive(notification.object as! Call)
    }

    @objc private func isConnecting(_ notification: Notification) {
        target.isConnecting(notification.object as! Call)
    }

    @objc private func didDisconnect(_ notification: Notification) {
        target.didDisconnect(notification.object as! Call)
    }
}

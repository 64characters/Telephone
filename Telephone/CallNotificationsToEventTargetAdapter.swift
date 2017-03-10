//
//  CallNotificationsToEventTargetAdapter.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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

final class CallNotificationsToEventTargetAdapter {
    private let center: NotificationCenter
    private let target: CallEventTarget

    init(center: NotificationCenter, target: CallEventTarget) {
        self.center = center
        self.target = target
        center.addObserver(
            self,
            selector: #selector(SIPCallDidDisconnect(_:)),
            name: Notification.Name.AKSIPCallDidDisconnect,
            object: nil
        )
    }

    deinit {
        center.removeObserver(self, name: Notification.Name.AKSIPCallDidDisconnect, object: nil)
    }

    @objc private func SIPCallDidDisconnect(_ notification: Notification) {
        target.didDisconnect(notification.object as! Call)
    }
}

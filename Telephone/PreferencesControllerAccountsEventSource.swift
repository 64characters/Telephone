//
//  PreferencesControllerAccountsEventSource.swift
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

final class PreferencesControllerAccountsEventSource {
    private let center: NotificationCenter
    private let target: AccountsEventTarget

    init(center: NotificationCenter, target: AccountsEventTarget) {
        self.center = center
        self.target = target
        center.addObserver(
            self, selector: #selector(didRemoveAccount), name: .AKPreferencesControllerDidRemoveAccount, object: nil
        )
    }

    deinit {
        center.removeObserver(self, name: .AKPreferencesControllerDidRemoveAccount, object: nil)
    }

    @objc private func didRemoveAccount(_ notification: Notification) {
        target.didRemoveAccount(withUUID: notification.userInfo![AKSIPAccountKeys.uuid] as! String)
    }
}

//
//  CNContactStoreNotificationsToContactsChangeEventTargetAdapter.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

import Contacts
import Foundation
import UseCases

@available(OSX 10.11, *)
final class CNContactStoreNotificationsToContactsChangeEventTargetAdapter {
    private let center: NotificationCenter
    private let target: ContactsChangeEventTarget

    init(center: NotificationCenter, target: ContactsChangeEventTarget) {
        self.center = center
        self.target = target
        center.addObserver(self, selector: #selector(contactsDidChange), name: .CNContactStoreDidChange, object: nil)
    }

    deinit {
        center.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
    }

    @objc private func contactsDidChange(_ notification: Notification) {
        target.contactsDidChange()
    }
}

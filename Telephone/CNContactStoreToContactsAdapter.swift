//
//  CNContactStoreToContactsAdapter.swift
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
import UseCases

@available(OSX 10.11, *)
final class CNContactStoreToContactsAdapter {
    fileprivate let store: CNContactStore

    init(store: CNContactStore) {
        self.store = store
    }
}

@available(OSX 10.11, *)
extension CNContactStoreToContactsAdapter: Contacts {
    func enumerate(_ body: @escaping (Contact) -> Void) {
        do {
            try store.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys)) { (contact, _) in
                body(Contact(contact))
            }
        } catch {
            NSLog("Could not enumerate contacts: \(error)")
        }
    }
}

@available(OSX 10.11, *)
private let keys = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor
]

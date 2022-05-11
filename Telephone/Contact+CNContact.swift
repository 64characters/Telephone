//
//  Contact+CNContact.swift
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

import Contacts
import UseCases

extension Contact {
    init(_ contact: CNContact) {
        self.init(
            name: CNContactFormatter.string(from: contact, style: .fullName) ?? "",
            phones: contact.phoneNumbers.map(Contact.Phone.init),
            emails: contact.emailAddresses.map(Contact.Email.init)
        )
    }
}

extension Contact.Phone {
    init(_ phone: CNLabeledValue<CNPhoneNumber>) {
        self.init(
            number: phone.value.stringValue,
            label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: phone.label ?? "")
        )
    }
}

extension Contact.Email {
    init(_ email: CNLabeledValue<NSString>) {
        self.init(
            address: email.value as String, label: CNLabeledValue<NSString>.localizedString(forLabel: email.label ?? "")
        )
    }
}

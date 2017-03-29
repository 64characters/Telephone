//
//  PresentationContact.swift
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

import Cocoa
import Foundation

final class PresentationContact: NSObject {
    let name: String
    let address: PresentationContactAddress
    let color: NSColor

    init(name: String, address: PresentationContactAddress, color: NSColor) {
        self.name = name
        self.address = address
        self.color = color
    }
}

extension PresentationContact {
    override func isEqual(_ object: Any?) -> Bool {
        guard let contact = object as? PresentationContact else { return false }
        return isEqual(to: contact)
    }

    override var hash: Int {
        return name.hash ^ address.hash ^ color.hash
    }

    private func isEqual(to contact: PresentationContact) -> Bool {
        return name == contact.name && address == contact.address && color == contact.color
    }
}

extension PresentationContact {
    convenience init(contact: Contact, color: NSColor) {
        self.init(
            name: contact.name,
            address: PresentationContactAddress(
                user: contact.address.origin.user, host: contact.address.origin.host, label: contact.address.label
            ),
            color: color
        )
    }
}

//
//  PresentationContact.swift
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
        if let contact = object as? PresentationContact {
            return isEqual(to: contact)
        } else {
            return false
        }
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

//
//  PresentationContactAddress.swift
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

import Foundation

final class PresentationContactAddress: NSObject {
    let user: String
    let host: String
    let label: String

    init(user: String, host: String, label: String) {
        self.user = user
        self.host = host
        self.label = label
    }
}

extension PresentationContactAddress {
    override func isEqual(_ object: Any?) -> Bool {
        guard let address = object as? PresentationContactAddress else { return false }
        return isEqual(to: address)
    }

    override var hash: Int {
        return user.hash ^ host.hash ^ label.hash
    }

    private func isEqual(to address: PresentationContactAddress) -> Bool {
        return user == address.user && host == address.host && label == address.label
    }
}

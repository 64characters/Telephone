//
//  LabeledContactAddress.swift
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

public struct LabeledContactAddress {
    public let origin: ContactAddress
    public let label: String

    public init(origin: ContactAddress, label: String) {
        self.origin = origin
        self.label = label
    }
}

extension LabeledContactAddress: Equatable {
    public static func ==(lhs: LabeledContactAddress, rhs: LabeledContactAddress) -> Bool {
        return lhs.origin == rhs.origin && lhs.label == rhs.label
    }
}

//
//  Product.swift
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

public struct Product: Hashable {
    public let identifier: String
    public let name: String
    public let price: Decimal
    public let localizedPrice: String

    public init(identifier: String, name: String, price: Decimal, localizedPrice: String) {
        self.identifier = identifier
        self.name = name
        self.price = price
        self.localizedPrice = localizedPrice
    }
}

extension Product: Comparable {
    public static func <(lhs: Product, rhs: Product) -> Bool {
        return lhs.price < rhs.price
    }
}

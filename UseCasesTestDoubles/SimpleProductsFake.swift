//
//  SimpleProductsFake.swift
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

import UseCases

public struct SimpleProductsFake {
    private let products: [String: Product] = [
        "123": Product(identifier: "123", name: "product1", price: 100, localizedPrice: "$100"),
        "456": Product(identifier: "456", name: "product2", price: 200, localizedPrice: "$200")
    ]

    public init() {}
}

extension SimpleProductsFake: Products {
    public var all: [Product] {
        return Array(products.values)
    }

    public subscript(identifier: String) -> Product? {
        return products[identifier]
    }

    public func fetch() {}
}

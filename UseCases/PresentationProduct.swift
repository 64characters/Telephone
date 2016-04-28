//
//  PresentationProduct.swift
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

public struct PresentationProduct {
    public let identifier: String
    public let name: String
    public let price: String

    public init(identifier: String, name: String, price: String) {
        self.identifier = identifier
        self.name = name
        self.price = price
    }
}

public extension PresentationProduct {
    init(_ product: Product) {
        self.init(identifier: product.identifier, name: product.name, price: product.localizedPrice)
    }
}

extension PresentationProduct: Equatable {}

public func ==(lhs: PresentationProduct, rhs: PresentationProduct) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.name == rhs.name && lhs.price == rhs.price
}

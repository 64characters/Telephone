//
//  StoreClientSpy.swift
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

import UseCases

public class StoreClientSpy {
    public private(set) var invokedIdentifiers: [String] = []
    public private(set) var invokedProduct: Product

    public init() {
        invokedProduct = Product(identifier: "", name: "", price: NSDecimalNumber.zero(), localizedPrice: "$0")
    }
}

extension StoreClientSpy: StoreClient {
    public func fetchProducts(withIdentifiers identifiers: [String]) {
        invokedIdentifiers = identifiers
    }

    public func purchase(product: Product) {
        invokedProduct = product
    }
}

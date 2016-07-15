//
//  ProductPurchaseEventTargetSpy.swift
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

public final class ProductPurchaseEventTargetSpy {
    public private(set) var didCallDidStartPurchasing = false
    public private(set) var didCallDidPurchase = false
    public private(set) var didCallDidFailPurchasing = false

    public private(set) var invokedProduct: Product
    public private(set) var invokedError = ""

    public init() {
        invokedProduct = Product(identifier: "", name: "", price: NSDecimalNumber.zero(), localizedPrice: "")
    }
}

extension ProductPurchaseEventTargetSpy: ProductPurchaseEventTarget {
    public func didStartPurchasing(product: Product) {
        didCallDidStartPurchasing = true
        invokedProduct = product
    }

    public func didPurchase(product: Product) {
        didCallDidPurchase = true
        invokedProduct = product
    }

    public func didFailPurchasing(product: Product, error: String) {
        didCallDidFailPurchasing = true
        invokedProduct = product
        invokedError = error
    }

    public func didFailPurchasing(product: Product) {
        didCallDidFailPurchasing = true
        invokedProduct = product
    }
}

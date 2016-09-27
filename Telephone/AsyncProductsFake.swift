//
//  AsyncProductsFake.swift
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

final class AsyncProductsFake {
    fileprivate let products: [String: Product]
    fileprivate let target: ProductsEventTarget
    fileprivate var attempts = 0

    init(target: ProductsEventTarget) {
        products = [
            "123": Product(
                identifier: "123",
                name: "1 Month",
                price: NSDecimalNumber(mantissa: 99, exponent: -2, isNegative: false),
                localizedPrice: "$0.99"
            ),
            "456": Product(
                identifier: "456",
                name: "12 Months",
                price: NSDecimalNumber(mantissa: 1099, exponent: -2, isNegative: false),
                localizedPrice: "$10.99"
            )
        ]
        self.target = target
    }
}

extension AsyncProductsFake: Products {
    var all: [Product] {
        return Array(products.values)
    }

    subscript(identifier: String) -> Product? {
        return products[identifier]
    }

    func fetch() {
        attempts += 1
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(UInt64(1.0) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC),
            execute: notifyTarget
        )
    }

    fileprivate func notifyTarget() {
        if attempts % 2 == 0 {
            notifyTargetWithError()
        } else {
            notifyTargetWithSuccess()
        }
    }

    fileprivate func notifyTargetWithSuccess() {
        target.productsDidFetch()
    }

    fileprivate func notifyTargetWithError() {
        target.productsDidFailFetching(error: "No network connection.")
    }
}

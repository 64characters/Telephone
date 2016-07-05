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

class AsyncProductsFake {
    var all: [Product] { return Array(products.values) }
    private let products: [String: Product]
    private let target: ProductsEventTarget
    private var attempts = 0

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
    subscript(identifier: String) -> Product? {
        return products[identifier]
    }

    func fetch() {
        attempts += 1
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(1.0) * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            notifyTarget
        )
    }

    private func notifyTarget() {
        if attempts % 2 == 0 {
            notifyTargetWithError()
        } else {
            notifyTargetWithSuccess()
        }
    }

    private func notifyTargetWithSuccess() {
        target.productsDidFetch()
    }

    private func notifyTargetWithError() {
        target.productsDidFailFetching(withError: "No network connection.")
    }
}

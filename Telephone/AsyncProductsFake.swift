//
//  AsyncProductsFake.swift
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

final class AsyncProductsFake {
    private let products: [String: Product]
    private let target: ProductsEventTarget
    private var attempts = 0

    init(target: ProductsEventTarget) {
        products = [
            "123": Product(identifier: "123", name: "1 Month", price: 0.99, localizedPrice: "$0.99"),
            "456": Product(identifier: "456", name: "12 Months", price: 10.99, localizedPrice: "$10.99")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: notifyTarget)
    }

    private func notifyTarget() {
        if attempts % 2 == 0 {
            notifyTargetWithError()
        } else {
            notifyTargetWithSuccess()
        }
    }

    private func notifyTargetWithSuccess() {
        target.didFetch(self)
    }

    private func notifyTargetWithError() {
        target.didFailFetching(self, error: "No network connection.")
    }
}

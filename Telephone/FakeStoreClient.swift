//
//  FakeStoreClient.swift
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

class FakeStoreClient {
    private let target: StoreClientEventTarget
    private var attempts = 0

    init(target: StoreClientEventTarget) {
        self.target = target
    }
}

extension FakeStoreClient: StoreClient {
    func fetchProducts(withIdentifiers identifiers: [String]) {
        attempts += 1
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(1.0) * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            notifyTarget
        )
    }

    func purchase(product: Product) {
        fatalError()
    }

    private func notifyTarget() {
        if attempts % 2 == 0 {
            notifyTargetWithError()
        } else {
            notifyTargetWithSuccess()
        }
    }

    private func notifyTargetWithSuccess() {
        target.storeClient(
            self,
            didFetchProducts: [
                Product(
                    identifier: "123",
                    name: "1 Month",
                    price: NSDecimalNumber(mantissa: 99, exponent: -2, isNegative: false),
                    localizedPrice: "$0.99"
                ),
                Product(
                    identifier: "456",
                    name: "12 Months",
                    price: NSDecimalNumber(mantissa: 1099, exponent: -2, isNegative: false),
                    localizedPrice: "$10.99"
                )
            ]
        )
    }

    private func notifyTargetWithError() {
        target.storeClient(self, didFailFetchingProductsWithError: "No network connection.")
    }
}

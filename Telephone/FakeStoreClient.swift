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
    let eventTarget: StoreClientEventTarget

    init(eventTarget: StoreClientEventTarget) {
        self.eventTarget = eventTarget
    }
}

extension FakeStoreClient: StoreClient {
    func fetchProducts(withIdentifiers identifiers: [String]) {
        dispatch_async(dispatch_get_main_queue(), notifyEventTarget)
    }

    private func notifyEventTarget() {
        eventTarget.storeClient(
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
}

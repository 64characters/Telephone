//
//  SKPaymentQueueToStoreAdapter.swift
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

import StoreKit

final class SKPaymentQueueToStoreAdapter {
    private let queue: SKPaymentQueue
    private let products: StoreKitProducts

    init(queue: SKPaymentQueue, products: StoreKitProducts) {
        self.queue = queue
        self.products = products
    }
}

extension SKPaymentQueueToStoreAdapter: Store {
    func purchase(product: Product) throws {
        queue.addPayment(try createPayment(withProduct: try storeKitProduct(forProduct: product)))
    }

    func restorePurchases() {

    }

    private func storeKitProduct(forProduct product: Product) throws -> SKProduct {
        if let result = products[product] {
            return result
        } else {
            throw TelephoneError.ProductToStoreKitProductMappingError
        }
    }
}

private func createPayment(withProduct product: SKProduct) throws -> SKPayment {
    if let result = SKPayment.paymentWithProduct(product) as? SKPayment {
        return result
    } else {
        throw TelephoneError.PaymentCreationError
    }
}

//
//  DefaultStoreClient.swift
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
import UseCases

class DefaultStoreClient: NSObject {
    let eventTarget: StoreClientEventTarget

    private var productsRequest: SKProductsRequest?

    init(eventTarget: StoreClientEventTarget) {
        self.eventTarget = eventTarget
    }
}

extension DefaultStoreClient: StoreClient {
    func fetchProducts(withIdentifiers identifiers: [String]) {
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productsRequest!.delegate = self
        productsRequest!.start()
    }
}

extension DefaultStoreClient: SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        eventTarget.storeClient(self, didFetchProducts: productsWithStoreKitProducts(response.products))
    }
}

extension DefaultStoreClient: SKRequestDelegate {
    func requestDidFinish(request: SKRequest) {
        forgetProductsRequest(request)
    }

    func request(request: SKRequest, didFailWithError error: NSError?) {
        NSLog("Store request '\(request)' failed: \(error)")
        notifyEventTargetAboutProductFetchFailure(request: request, error: descriptionOf(error))
        forgetProductsRequest(request)
    }

    private func notifyEventTargetAboutProductFetchFailure(request request: SKRequest, error: String) {
        if request === productsRequest {
            eventTarget.storeClient(self, didFailFetchingProductsWithError: error)
        }
    }

    private func forgetProductsRequest(request: SKRequest) {
        if request === productsRequest {
            productsRequest = nil
        }
    }
}

private func productsWithStoreKitProducts(products: [SKProduct]?) -> [Product] {
    if let products = products {
        return productsWithStoreKitProducts(products)
    } else {
        return []
    }
}

private func productsWithStoreKitProducts(products: [SKProduct]) -> [Product] {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    return products.map { product in
        formatter.locale = product.priceLocale
        return Product(product: product, formatter: formatter)
    }
}

private func descriptionOf(error: NSError?) -> String {
    return error?.localizedDescription ?? "Unknown error"
}

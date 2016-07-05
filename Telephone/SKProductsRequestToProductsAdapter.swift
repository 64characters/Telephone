//
//  SKProductsRequestToProductsAdapter.swift
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

class SKProductsRequestToProductsAdapter: NSObject {
    var all: [Product] { return Array(products.values) }
    private var products: [String: Product] = [:]
    private var request: SKProductsRequest?

    private let identifiers: [String]
    private let target: ProductsEventTarget

    init(identifiers: [String], target: ProductsEventTarget) {
        self.identifiers = identifiers
        self.target = target
    }
}

extension SKProductsRequestToProductsAdapter: Products {
    subscript(identifier: String) -> Product? {
        return products[identifier]
    }

    func fetch() {
        request?.cancel()
        request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request!.delegate = self
        request!.start()
    }
}

extension SKProductsRequestToProductsAdapter: SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        dispatch_async(dispatch_get_main_queue()) {
            self.products = identifierToProduct(fromProducts: productsWithStoreKitProducts(response.products))
            self.target.productsDidFetch()
        }
    }
}

extension SKProductsRequestToProductsAdapter: SKRequestDelegate {
    func requestDidFinish(request: SKRequest) {
        dispatch_async(dispatch_get_main_queue()) {
            self.forgetProductsRequest(request)
        }
    }

    func request(request: SKRequest, didFailWithError error: NSError?) {
        NSLog("Store request '\(request)' failed: \(error)")
        dispatch_async(dispatch_get_main_queue()) {
            self.notifyEventTargetAboutProductFetchFailure(request: request, error: descriptionOf(error))
            self.forgetProductsRequest(request)
        }
    }

    private func notifyEventTargetAboutProductFetchFailure(request request: SKRequest, error: String) {
        if request === self.request {
            self.target.productsDidFailFetching(withError: error)
        }
    }

    private func forgetProductsRequest(request: SKRequest) {
        if request === self.request {
            self.request = nil
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

private func identifierToProduct(fromProducts products: [Product]) -> [String: Product] {
    var result: [String: Product] = [:]
    products.forEach { result[$0.identifier] = $0 }
    return result
}

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

final class SKProductsRequestToProductsAdapter: NSObject {
    private var products: [String: Product] = [:]
    private var storeKitProducts: [Product: SKProduct] = [:]
    private var request: SKProductsRequest?

    private let expected: ExpectedProducts
    private let target: ProductsEventTarget

    init(expected: ExpectedProducts, target: ProductsEventTarget) {
        self.expected = expected
        self.target = target
    }
}

extension SKProductsRequestToProductsAdapter: Products {
    var all: [Product] {
        return Array(products.values)
    }

    subscript(identifier: String) -> Product? {
        return products[identifier]
    }

    func fetch() {
        request?.cancel()
        request = SKProductsRequest(productIdentifiers: expected.identifiers)
        request!.delegate = self
        request!.start()
    }
}

extension SKProductsRequestToProductsAdapter: StoreKitProducts {
    subscript(product: Product) -> SKProduct? {
        return storeKitProducts[product]
    }
}

extension SKProductsRequestToProductsAdapter: SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        dispatch_async(dispatch_get_main_queue()) {
            (self.products, self.storeKitProducts) = self.productMaps(withProducts: response.products)
            self.target.productsDidFetch()
        }
    }

    private func productMaps(withProducts products: [SKProduct]?) -> ([String: Product], [Product: SKProduct]) {
        if let products = products {
            return productMaps(withProducts: products)
        } else {
            return ([:], [:])
        }
    }

    private func productMaps(withProducts products: [SKProduct]) -> ([String: Product], [Product: SKProduct]) {
        var idToProduct: [String: Product] = [:]
        var productToSKProduct: [Product: SKProduct] = [:]
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        for skProduct in products {
            formatter.locale = skProduct.priceLocale
            let product = Product(
                product: skProduct, name: expected.name(withIdentifier: skProduct.productIdentifier!), formatter: formatter
            )
            idToProduct[product.identifier] = product
            productToSKProduct[product] = skProduct
        }
        return (idToProduct, productToSKProduct)
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

private func descriptionOf(error: NSError?) -> String {
    return error?.localizedDescription ?? NSLocalizedString("Unknown error", comment: "Unknown error.")
}

private func identifierToProduct(fromProducts products: [Product]) -> [String: Product] {
    var result: [String: Product] = [:]
    products.forEach { result[$0.identifier] = $0 }
    return result
}

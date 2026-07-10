//
//  SKProductsRequestToProductsAdapter.swift
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

import StoreKit
import UseCases

@MainActor
final class SKProductsRequestToProductsAdapter: NSObject {
    private var products: [String: UseCases.Product] = [:]
    private var storeKitProducts: [UseCases.Product: SKProduct] = [:]
    private var request: SKProductsRequest?

    private let expected: ExpectedProducts
    private let target: ProductsEventTarget

    init(expected: ExpectedProducts, target: ProductsEventTarget) {
        self.expected = expected
        self.target = target
    }
}

extension SKProductsRequestToProductsAdapter: @preconcurrency Products {
    var all: [UseCases.Product] {
        return Array(products.values)
    }

    subscript(identifier: String) -> UseCases.Product? {
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
    subscript(product: UseCases.Product) -> SKProduct? {
        return storeKitProducts[product]
    }
}

extension SKProductsRequestToProductsAdapter: SKProductsRequestDelegate {
    nonisolated func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Task { @MainActor in
            (products, storeKitProducts) = productMaps(with: response.products)
            target.didFetch(self)
        }
    }

    private func productMaps(with products: [SKProduct]?) -> ([String: UseCases.Product], [UseCases.Product: SKProduct]) {
        if let products = products {
            return productMaps(with: products)
        } else {
            return ([:], [:])
        }
    }

    private func productMaps(with products: [SKProduct]) -> ([String: UseCases.Product], [UseCases.Product: SKProduct]) {
        var idToProduct: [String: UseCases.Product] = [:]
        var productToSKProduct: [UseCases.Product: SKProduct] = [:]
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        for skProduct in products {
            formatter.locale = skProduct.priceLocale
            let product = Product(
                product: skProduct, name: expected.name(withIdentifier: skProduct.productIdentifier), formatter: formatter
            )
            idToProduct[product.identifier] = product
            productToSKProduct[product] = skProduct
        }
        return (idToProduct, productToSKProduct)
    }
}

extension SKProductsRequestToProductsAdapter: SKRequestDelegate {
    nonisolated func requestDidFinish(_ request: SKRequest) {
        Task { @MainActor in
            self.request = nil
        }
    }

    nonisolated func request(_ request: SKRequest, didFailWithError error: Error) {
        NSLog("Store request '\(request)' failed: \(error)")
        Task { @MainActor in
            target.didFailFetching(self, error: descriptionOf(error))
            self.request = nil
        }
    }
}

private func descriptionOf(_ error: Error) -> String {
    if error.localizedDescription.isEmpty {
        return NSLocalizedString("Unknown error", comment: "Unknown error.")
    } else {
        return error.localizedDescription
    }
}

private func identifierToProduct(fromProducts products: [UseCases.Product]) -> [String: UseCases.Product] {
    var result: [String: UseCases.Product] = [:]
    products.forEach { result[$0.identifier] = $0 }
    return result
}

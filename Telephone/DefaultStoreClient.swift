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
    private let target: StoreClientEventTarget
    private var request: SKProductsRequest?

    init(target: StoreClientEventTarget) {
        self.target = target
    }
}

extension DefaultStoreClient: StoreClient {
    func fetchProducts(withIdentifiers identifiers: [String]) {
        request?.cancel()
        request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request!.delegate = self
        request!.start()
    }

    func purchase(product: Product) {
        fatalError()
    }
}

extension DefaultStoreClient: SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        dispatch_async(dispatch_get_main_queue()) {
            self.target.storeClient(self, didFetchProducts: productsWithStoreKitProducts(response.products))
        }
    }
}

extension DefaultStoreClient: SKRequestDelegate {
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
            target.storeClient(self, didFailFetchingProductsWithError: error)
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

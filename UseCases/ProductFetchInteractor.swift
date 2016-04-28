//
//  ProductFetchInteractor.swift
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

public protocol ProductFetchInteractorOutput {
    func didFetchProducts(products: [Product])
    func didFailFetchingProducts(error: String)
}

public class ProductFetchInteractor {
    let identifiers: [String]
    let client: StoreClient
    let output: ProductFetchInteractorOutput

    public init(productIdentifiers: [String], client: StoreClient, output: ProductFetchInteractorOutput) {
        identifiers = productIdentifiers
        self.client = client
        self.output = output
    }
}

extension ProductFetchInteractor: Interactor {
    public func execute() {
        client.fetchProducts(withIdentifiers: identifiers)
    }
}

extension ProductFetchInteractor: StoreClientEventTarget {
    public func storeClient(storeClient: StoreClient, didFetchProducts products: [Product]) {
        output.didFetchProducts(products)
    }

    public func storeClient(storeClient: StoreClient, didFailFetchingProductsWithError error: String) {
        output.didFailFetchingProducts(error)
    }
}

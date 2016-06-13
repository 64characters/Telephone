//
//  ProductsFetchInteractor.swift
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

public protocol ProductsFetchInteractorOutput: class {
    func didFetchProducts(products: [Product])
    func didFailFetchingProducts(error error: String)
}

public class ProductsFetchInteractor {
    private let identifiers: [String]
    private let client: StoreClient
    private let targets: StoreClientEventTargets
    private let output: ProductsFetchInteractorOutput

    public init(productIdentifiers: [String], client: StoreClient, targets: StoreClientEventTargets, output: ProductsFetchInteractorOutput) {
        identifiers = productIdentifiers
        self.client = client
        self.targets = targets
        self.output = output
    }
}

extension ProductsFetchInteractor: Interactor {
    public func execute() {
        targets.addTarget(self)
        client.fetchProducts(withIdentifiers: identifiers)
    }
}

extension ProductsFetchInteractor: StoreClientEventTarget {
    public func storeClient(storeClient: StoreClient, didFetchProducts products: [Product]) {
        output.didFetchProducts(products)
        targets.removeTarget(self)
    }

    public func storeClient(storeClient: StoreClient, didFailFetchingProductsWithError error: String) {
        output.didFailFetchingProducts(error: error)
        targets.removeTarget(self)
    }
}

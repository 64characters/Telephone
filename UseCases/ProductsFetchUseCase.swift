//
//  ProductsFetchUseCase.swift
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

public protocol ProductsFetchUseCaseOutput: class {
    func didFetchProducts(products: [Product])
    func didFailFetchingProducts(error error: String)
}

public class ProductsFetchUseCase {
    private let products: Products
    private let targets: ProductsEventTargets
    private let output: ProductsFetchUseCaseOutput

    public init(products: Products, targets: ProductsEventTargets, output: ProductsFetchUseCaseOutput) {
        self.products = products
        self.targets = targets
        self.output = output
    }
}

extension ProductsFetchUseCase: UseCase {
    public func execute() {
        targets.addTarget(self)
        products.fetch()
    }
}

extension ProductsFetchUseCase: ProductsEventTarget {
    public func productsDidFetch() {
        output.didFetchProducts(products.all)
        targets.removeTarget(self)
    }

    public func productsDidFailFetching(withError error: String) {
        output.didFailFetchingProducts(error: error)
        targets.removeTarget(self)
    }
}

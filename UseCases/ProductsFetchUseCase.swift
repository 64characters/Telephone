//
//  ProductsFetchUseCase.swift
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

public protocol ProductsFetchUseCaseOutput: AnyObject {
    func didFetch(_ products: [Product])
    func didFailFetchingProducts(error: String)
}

public final class ProductsFetchUseCase {
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
        targets.add(self)
        products.fetch()
    }
}

extension ProductsFetchUseCase: ProductsEventTarget {
    public func didFetch(_ products: Products) {
        output.didFetch(products.all)
        targets.remove(self)
    }

    public func didFailFetching(_ products: Products, error: String) {
        output.didFailFetchingProducts(error: error)
        targets.remove(self)
    }
}

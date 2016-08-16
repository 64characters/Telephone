//
//  DefaultStoreUseCaseFactory.swift
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

import UseCases

final class DefaultStoreUseCaseFactory {
    private let products: Products
    private let store: Store
    private let targets: ProductsEventTargets

    init(products: Products, store: Store, targets: ProductsEventTargets) {
        self.products = products
        self.store = store
        self.targets = targets
    }
}

extension DefaultStoreUseCaseFactory: StoreUseCaseFactory {
    func createProductsFetchUseCase(output output: ProductsFetchUseCaseOutput) -> UseCase {
        return ProductsFetchUseCase(products: products, targets: targets, output: output)
    }

    func createProductPurchaseUseCase(identifier identifier: String) -> ThrowingUseCase {
        return ProductPurchaseUseCase(identifier: identifier, products: products, store: store)
    }
}

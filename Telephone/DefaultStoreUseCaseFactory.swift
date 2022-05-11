//
//  DefaultStoreUseCaseFactory.swift
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

import UseCases

final class DefaultStoreUseCaseFactory {
    private let products: Products
    private let store: Store
    private let receipt: Receipt
    private let targets: ProductsEventTargets

    init(products: Products, store: Store, receipt: Receipt, targets: ProductsEventTargets) {
        self.products = products
        self.store = store
        self.receipt = receipt
        self.targets = targets
    }
}

extension DefaultStoreUseCaseFactory: StoreUseCaseFactory {
    func makePurchaseCheckUseCase(output: PurchaseCheckUseCaseOutput) -> UseCase {
        return PurchaseCheckUseCase(receipt: receipt, output: output)
    }

    func makeProductsFetchUseCase(output: ProductsFetchUseCaseOutput) -> UseCase {
        return ProductsFetchUseCase(products: products, targets: targets, output: output)
    }

    func makeProductPurchaseUseCase(identifier: String) -> ThrowingUseCase {
        return ProductPurchaseUseCase(identifier: identifier, products: products, store: store)
    }
}

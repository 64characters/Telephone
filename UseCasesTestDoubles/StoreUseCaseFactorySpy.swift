//
//  StoreUseCaseFactorySpy.swift
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

public class StoreUseCaseFactorySpy {
    private var fetch: UseCase!
    private var purchase: UseCase!

    public private(set) var invokedIdentifier = ""

    public init() {}

    public func stub(withProductsFetch fetch: UseCase) {
        self.fetch = fetch
    }

    public func stub(withProductPurchase purchase: UseCase) {
        self.purchase = purchase
    }
}

extension StoreUseCaseFactorySpy: StoreUseCaseFactory {
    public func createProductsFetchUseCase(output output: ProductsFetchUseCaseOutput) -> UseCase {
        return fetch
    }

    public func createProductPurchaseUseCase(identifier identifier: String) -> UseCase {
        invokedIdentifier = identifier
        return purchase
    }
}

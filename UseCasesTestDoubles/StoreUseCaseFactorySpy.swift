//
//  StoreUseCaseFactorySpy.swift
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

public final class StoreUseCaseFactorySpy {
    private var check: UseCase!
    private var fetch: UseCase!
    private var purchase: ThrowingUseCase!

    public private(set) var invokedIdentifier = ""

    public init() {}

    public func stub(withPurchaseCheck check: UseCase) {
        self.check = check
    }

    public func stub(withProductsFetch fetch: UseCase) {
        self.fetch = fetch
    }

    public func stub(withProductPurchase purchase: ThrowingUseCase) {
        self.purchase = purchase
    }
}

extension StoreUseCaseFactorySpy: StoreUseCaseFactory {
    public func makePurchaseCheckUseCase(output: PurchaseCheckUseCaseOutput) -> UseCase {
        return check
    }

    public func makeProductsFetchUseCase(output: ProductsFetchUseCaseOutput) -> UseCase {
        return fetch
    }

    public func makeProductPurchaseUseCase(identifier: String) -> ThrowingUseCase {
        invokedIdentifier = identifier
        return purchase
    }
}

//
//  StoreKitTransactionStoreEventSource.swift
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

final class StoreKitTransactionStoreEventSource {
    private let updates: Task<Void, Never>

    init(target: StoreEventTarget) {
        updates = startTransactionUpdateListener(target: target)
    }

    deinit {
        updates.cancel()
    }
}

private func startTransactionUpdateListener(target: StoreEventTarget) -> Task<Void, Never> {
    Task {
        for await verification in Transaction.updates {
            if case .verified(let transaction) = verification {
                await transaction.finish()
                await target.didPurchase()
            }
        }
    }
}

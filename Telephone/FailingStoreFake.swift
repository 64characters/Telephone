//
//  FailingStoreFake.swift
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

@MainActor
final class FailingStoreFake {
    private var attempts = 0
    private var target: StoreEventTarget

    init(target: StoreEventTarget) {
        self.target = target
    }

    func updateTarget(_ target: StoreEventTarget) {
        self.target = target
    }
}

extension FailingStoreFake: @preconcurrency Store {
    func purchase(_ product: Product) throws {
        attempts += 1
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            target.didStartPurchasingProduct(withIdentifier: product.identifier)
            try? await Task.sleep(for: .seconds(1))
            notifyTargetAboutPurchaseFailure()
        }
    }

    func restorePurchases() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            target.didFailRestoringPurchases(error: error)
        }
    }

    private func notifyTargetAboutPurchaseFailure() {
        if attempts % 2 == 0 {
            target.didCancelPurchasing()
        } else {
            target.didFailPurchasing(error: error)
        }
    }
}

private let error = "The store returned a terrible error. Please try again later."

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

extension FailingStoreFake: Store {
    func purchase(_ product: Product) throws {
        attempts += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.target.didStartPurchasingProduct(withIdentifier: product.identifier)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.notifyTargetAboutPurchaseFailure()
        }
    }

    func restorePurchases() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.target.didFailRestoringPurchases(error: error)
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

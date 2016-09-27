//
//  FailingStoreFake.swift
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

final class FailingStoreFake {
    fileprivate var attempts = 0
    fileprivate var target: StoreEventTarget

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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(0.2) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            self.target.didStartPurchasingProduct(withIdentifier: product.identifier)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(1.0) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            self.notifyTargetAboutPurchaseFailure()
        }
    }

    func restorePurchases() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(1.0) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            self.target.didFailRestoringPurchases(error: error)
        }
    }

    fileprivate func notifyTargetAboutPurchaseFailure() {
        if attempts % 2 == 0 {
            target.didCancelPurchasingProducts()
        } else {
            target.didFailPurchasingProducts(error: error)
        }
    }
}

private let error = "The store returned a terrible error. Please try again later."

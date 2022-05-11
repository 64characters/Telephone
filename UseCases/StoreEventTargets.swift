//
//  StoreEventTargets.swift
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

public final class StoreEventTargets {
    private var targets: [StoreEventTarget] = []

    public init() {}

    public func add(_ target: StoreEventTarget) {
        targets.append(target)
    }
}

extension StoreEventTargets: StoreEventTarget {
    public func didStartPurchasingProduct(withIdentifier identifier: String) {
        targets.forEach { $0.didStartPurchasingProduct(withIdentifier: identifier) }
    }

    public func didPurchase() {
        targets.forEach { $0.didPurchase() }
     }

    public func didFailPurchasing(error: String) {
        targets.forEach { $0.didFailPurchasing(error: error) }
    }

    public func didCancelPurchasing() {
        targets.forEach { $0.didCancelPurchasing() }
    }

    public func didRestorePurchases() {
        targets.forEach { $0.didRestorePurchases() }
    }

    public func didFailRestoringPurchases(error: String) {
        targets.forEach { $0.didFailRestoringPurchases(error: error) }
    }

    public func didCancelRestoringPurchases() {
        targets.forEach { $0.didCancelRestoringPurchases() }
    }
}

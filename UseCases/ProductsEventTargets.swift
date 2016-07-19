//
//  ProductsEventTargets.swift
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

public final class ProductsEventTargets {
    public var count: Int {
        return targets.count
    }

    public subscript(index: Int) -> ProductsEventTarget? {
        get {
            return targets[index]
        }
    }

    private var targets: [ProductsEventTarget] = []

    public init() {}

    public func addTarget(target: ProductsEventTarget) {
        targets.append(target)
    }

    public func removeTarget(target: ProductsEventTarget) {
        if let index = targets.indexOf({ $0 === target }) {
            targets.removeAtIndex(index)
        }
    }
}

extension ProductsEventTargets: ProductsEventTarget {
    public func productsDidFetch() {
        targets.forEach() { $0.productsDidFetch() }
    }

    public func productsDidFailFetching(withError error: String) {
        targets.forEach { $0.productsDidFailFetching(withError: error) }
    }
}

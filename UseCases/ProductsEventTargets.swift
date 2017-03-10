//
//  ProductsEventTargets.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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

    fileprivate var targets: [ProductsEventTarget] = []

    public init() {}

    public func add(_ target: ProductsEventTarget) {
        targets.append(target)
    }

    public func remove(_ target: ProductsEventTarget) {
        if let index = targets.index(where: { $0 === target }) {
            targets.remove(at: index)
        }
    }
}

extension ProductsEventTargets: ProductsEventTarget {
    public func didFetch(_ products: Products) {
        targets.forEach() { $0.didFetch(products) }
    }

    public func didFailFetching(_ products: Products, error: String) {
        targets.forEach { $0.didFailFetching(products, error: error) }
    }
}

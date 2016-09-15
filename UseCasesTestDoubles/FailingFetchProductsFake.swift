//
//  FailingFetchProductsFake.swift
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

public final class FailingFetchProductsFake {
    public fileprivate(set) var all: [Product] = []
    public let error = "error"
    fileprivate let target: ProductsEventTarget

    public init(target: ProductsEventTarget) {
        self.target = target
    }
}

extension FailingFetchProductsFake: Products {
    public subscript(identifier: String) -> Product? {
        return nil
    }

    public func fetch() {
        target.productsDidFailFetching(withError: "error")
    }
}

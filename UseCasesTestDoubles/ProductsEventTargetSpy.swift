//
//  ProductsEventTargetSpy.swift
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

public final class ProductsEventTargetSpy {
    public private(set) var didCallDidFetch = false
    public private(set) var didCallDidFailFetching = false

    public init() {}
}

extension ProductsEventTargetSpy: ProductsEventTarget {
    public func didFetch(_ products: Products) {
        didCallDidFetch = true
    }

    public func didFailFetching(_ products: Products, error: String) {
        didCallDidFailFetching = true
    }
}

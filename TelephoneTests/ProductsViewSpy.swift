//
//  ProductsViewSpy.swift
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

class ProductsViewSpy {
    private(set) var invokedProducts: [PresentationProduct] = []
    private(set) var invokedError = ""
}

extension ProductsViewSpy: ProductsView {}

extension ProductsViewSpy: ProductsFetchPresenterOutput {
    func showProducts(products: [PresentationProduct]) {
        invokedProducts = products
    }

    func showProductFetchError(error: String) {
        invokedError = error
    }
}

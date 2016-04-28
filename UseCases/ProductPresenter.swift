//
//  ProductPresenter.swift
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

public protocol ProductPresenterOutput {
    func showProducts(products: [PresentationProduct])
    func showError(error: String)
}

public class ProductPresenter {
    let output: ProductPresenterOutput

    public init(output: ProductPresenterOutput) {
        self.output = output
    }
}

extension ProductPresenter: ProductFetchInteractorOutput {
    public func didFetchProducts(products: [Product]) {
        output.showProducts(products.sort(hasLowerPrice).map({PresentationProduct($0)}))
    }

    public func didFailFetchingProducts(error: String) {
        output.showError(error)
    }
}

private func hasLowerPrice(lhs: Product, _ rhs: Product) -> Bool {
    return lhs.price.compare(rhs.price) == .OrderedAscending
}

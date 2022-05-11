//
//  Product+SKProduct.swift
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

import StoreKit
import UseCases

extension UseCases.Product {
    init(product: SKProduct, name: String, formatter: NumberFormatter) {
        self.init(
            identifier: product.productIdentifier,
            name: name,
            price: product.price as Decimal,
            localizedPrice: localized(product.price, formatter: formatter)
        )
    }
}

private func localized(_ price: NSDecimalNumber?, formatter: NumberFormatter) -> String {
    if let number = price, let string = formatter.string(from: number) {
        return string
    } else {
        return "N/A"
    }
}

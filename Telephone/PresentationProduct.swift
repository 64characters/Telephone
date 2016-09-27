//
//  PresentationProduct.swift
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

final class PresentationProduct: NSObject {
    let identifier: String
    let name: String
    let price: String

    init(identifier: String, name: String, price: String) {
        self.identifier = identifier
        self.name = name
        self.price = price
    }
}

extension PresentationProduct {
    override func isEqual(_ object: Any?) -> Bool {
        if let product = object as? PresentationProduct {
            return isEqualToProduct(product)
        } else {
            return false
        }
    }

    override var hash: Int {
        return identifier.hash ^ name.hash ^ price.hash
    }

    func isEqualToProduct(_ product: PresentationProduct) -> Bool {
        return self.identifier == product.identifier && self.name == product.name && self.price == product.price
    }
}

extension PresentationProduct {
    convenience init(_ product: Product) {
        self.init(identifier: product.identifier, name: product.name, price: product.localizedPrice)
    }
}

//
//  PresentationProduct.swift
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

final class PresentationProduct: NSObject {
    let identifier: String
    @objc let name: String
    @objc let price: String

    init(identifier: String, name: String, price: String) {
        self.identifier = identifier
        self.name = name
        self.price = price
    }
}

extension PresentationProduct {
    override func isEqual(_ object: Any?) -> Bool {
        guard let product = object as? PresentationProduct else { return false }
        return isEqual(toProduct: product)
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(name)
        hasher.combine(price)
        return hasher.finalize()
    }

    func isEqual(toProduct product: PresentationProduct) -> Bool {
        return self.identifier == product.identifier && self.name == product.name && self.price == product.price
    }
}

extension PresentationProduct {
    convenience init(_ product: Product) {
        self.init(identifier: product.identifier, name: product.name, price: product.localizedPrice)
    }
}

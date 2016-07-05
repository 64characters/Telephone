//
//  AsyncFailingProductsFake.swift
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

class AsyncFailingProductsFake {
    let all: [Product] = []
    private let target: ProductsEventTarget

    init(target: ProductsEventTarget) {
        self.target = target
    }
}

extension AsyncFailingProductsFake: Products {
    subscript(identifier: String) -> Product? {
        return nil
    }

    func fetch() {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(1.0) * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            notifyTarget
        )
    }

    private func notifyTarget() {
        target.productsDidFailFetching(withError: "Network is unreachable.")
    }
}

//
//  AsyncFailingProductsFake.swift
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

final class AsyncFailingProductsFake {
    let all: [Product] = []
    fileprivate let target: ProductsEventTarget

    init(target: ProductsEventTarget) {
        self.target = target
    }
}

extension AsyncFailingProductsFake: Products {
    subscript(identifier: String) -> Product? {
        return nil
    }

    func fetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: notifyTarget)
    }

    private func notifyTarget() {
        target.didFailFetching(self, error: "Network is unreachable.")
    }
}

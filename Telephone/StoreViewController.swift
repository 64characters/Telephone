//
//  StoreViewController.swift
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

import Cocoa
import UseCases

class StoreViewController: NSViewController {
    private var target: StoreViewEventTarget = NullStoreViewEventTarget()
    private dynamic var products: [PresentationProduct] = []

    init() {
        super.init(nibName: "StoreViewController", bundle: nil)!
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        target.viewShouldReloadData(self)
    }

    func updateEventTarget(target: StoreViewEventTarget) {
        self.target = target
    }
}

extension StoreViewController: StoreView {
    func showProducts(products: [PresentationProduct]) {
        self.products = products
    }

    func showProductFetchError(error: String) {

    }
}

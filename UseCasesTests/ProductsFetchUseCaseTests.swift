//
//  ProductsFetchUseCaseTests.swift
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
import UseCasesTestDoubles
import XCTest

final class ProductsFetchUseCaseTests: XCTestCase {
    func testCallsOutputWithFetchedProducts() {
        let targets = ProductsEventTargets()
        let products = SuccessfulFetchProductsFake(target: targets)
        let output = ProductsFetchUseCaseOutputSpy();
        let sut = ProductsFetchUseCase(products: products, targets: targets, output: output)

        sut.execute()

        XCTAssertEqual(output.invokedProducts, products.all)
    }

    func testCallsOutputWithErrorMessageWhenProductFetchFails() {
        let targets = ProductsEventTargets()
        let products = FailingFetchProductsFake(target: targets)
        let output = ProductsFetchUseCaseOutputSpy();
        let sut = ProductsFetchUseCase(products: products, targets: targets, output: output)

        sut.execute()

        XCTAssertEqual(output.invokedError, products.error)
    }

    func testRemovesItselfFromTargetsOnFetchSuccess() {
        let targets = ProductsEventTargets()
        let products = SuccessfulFetchProductsFake(target: targets)
        let sut = ProductsFetchUseCase(products: products, targets: targets, output: ProductsFetchUseCaseOutputSpy())

        sut.execute()

        XCTAssertEqual(targets.count, 0)
    }

    func testRemovesItselfFromTargetsOnFetchFailure() {
        let targets = ProductsEventTargets()
        let products = FailingFetchProductsFake(target: targets)
        let sut = ProductsFetchUseCase(products: products, targets: targets, output: ProductsFetchUseCaseOutputSpy())
        
        sut.execute()

        XCTAssertEqual(targets.count, 0)
    }
}

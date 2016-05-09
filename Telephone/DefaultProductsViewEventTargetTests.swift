//
//  DefaultProductsViewEventTargetTests.swift
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

import UseCases
import UseCasesTestDoubles
import XCTest

class DefaultProductsViewEventTargetTests: XCTestCase {
    func testCreatesInteractorWithOutputFromPresenterFactory() {
        let interactorFactory = ProductFetchInteractorFactorySpy(interactor: InteractorSpy())
        let presenter = ProductPresenter(output: ProductPresenterOutputSpy())
        let presenterFactory = PresenterFactoryStub()
        presenterFactory.stubWithProductPresenter(presenter)
        let sut = DefaultProductsViewEventTarget(interactorFactory: interactorFactory, presenterFactory: presenterFactory)

        sut.viewShouldReloadData(ProductsViewDummy())

        XCTAssertTrue(interactorFactory.invokedOutput === presenter)
    }

    func testExecutesInteractorOnViewShouldReload() {
        let interactor = InteractorSpy()
        let sut = DefaultProductsViewEventTarget(
            interactorFactory: ProductFetchInteractorFactorySpy(interactor: interactor),
            presenterFactory: DefaultPresenterFactory()
        )

        sut.viewShouldReloadData(ProductsViewDummy())

        XCTAssertTrue(interactor.didCallExecute)
    }
}

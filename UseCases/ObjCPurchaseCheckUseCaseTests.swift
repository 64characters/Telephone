//
//  ObjCPurchaseCheckUseCaseTests.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

final class ObjCPurchaseCheckUseCaseTests: XCTestCase {
    func testCallsExecuteOnPurchaseCheckUseCaseFromFactoryOnExecute() {
        let check = UseCaseSpy()
        let factory = StoreUseCaseFactorySpy()
        factory.stub(withPurchaseCheck: check)
        let sut = ObjCPurchaseCheckUseCase(factory: factory, output: PurchaseCheckUseCaseOutputSpy())

        sut.execute()

        XCTAssertTrue(check.didCallExecute)
    }

    func testCallsDidCheckPurchaseWithTheSameArgumentOnOutputOnDidCheckPurchase() {
        let output = PurchaseCheckUseCaseOutputSpy()
        let sut = ObjCPurchaseCheckUseCase(factory: StoreUseCaseFactorySpy(), output: output)
        let date = Date()

        sut.didCheckPurchase(expiration: date)

        XCTAssertTrue(output.didCallDidCheckPurchase)
        XCTAssertEqual(output.invokedExpiration, date)
    }

    func testCallsDidFailCheckingPurchaseOnOutputOnDidFailCheckingPurchase() {
        let output = PurchaseCheckUseCaseOutputSpy()
        let sut = ObjCPurchaseCheckUseCase(factory: StoreUseCaseFactorySpy(), output: output)

        sut.didFailCheckingPurchase()

        XCTAssertTrue(output.didCallDidFailCheckingPurchase)
    }
}

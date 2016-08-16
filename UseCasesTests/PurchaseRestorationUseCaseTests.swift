//
//  PurchaseRestorationUseCaseTests.swift
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

final class PurchaseRestorationUseCaseTests: XCTestCase {
    func testStartsReceiptRefreshOnExecute() {
        let request = ReceiptRefreshRequestSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: request),
            output: PurchaseRestorationUseCaseOutputSpy()
        )

        sut.execute()

        XCTAssertTrue(request.didCallStart)
    }

    func testCallsDidRestorePurchasesOnDidRefreshReceiptWhenReceiptIsValidAndThereAreActivePurchases() {
        let output = PurchaseRestorationUseCaseOutputSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: ReceiptRefreshRequestSpy()),
            output: output
        )

        sut.didRefreshReceipt(ValidReceipt())

        XCTAssertTrue(output.didCallDidRestorePurchases)
    }

    func testCallsDidFailRestoringPurchasesOnDidRefreshReceiptWhenReceiptIsNotValid() {
        let output = PurchaseRestorationUseCaseOutputSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: ReceiptRefreshRequestSpy()),
            output: output
        )

        sut.didRefreshReceipt(InvalidReceipt())

        XCTAssertTrue(output.didCallDidFailRestoringPurchases)
        XCTAssertEqual(output.invokedError, ReceiptValidationResult.ReceiptIsInvalid.message)
    }

    func testCallsDidFailRestoringPurchasesOnDidRefreshReceiptWhenReceiptDoesNotHaveActivePurchases() {
        let output = PurchaseRestorationUseCaseOutputSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: ReceiptRefreshRequestSpy()),
            output: output
        )

        sut.didRefreshReceipt(NoActivePurchasesReceipt())

        XCTAssertTrue(output.didCallDidFailRestoringPurchases)
        XCTAssertEqual(output.invokedError, ReceiptValidationResult.NoActivePurchases.message)
    }

    func testCallsDidFailRestoringPurchasesOnDidFailRefreshingReceipt() {
        let output = PurchaseRestorationUseCaseOutputSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: ReceiptRefreshRequestSpy()),
            output: output
        )
        let error = "any"

        sut.didFailRefreshingReceipt(error: error)

        XCTAssertTrue(output.didCallDidFailRestoringPurchases)
        XCTAssertEqual(output.invokedError, error)
    }

    func testDoesNotStartReceiptRefreshOnExecuteWhenPreviousRefreshIsNotFinished() {
        let request = ReceiptRefreshRequestSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: request),
            output: PurchaseRestorationUseCaseOutputSpy()
        )

        sut.execute()
        sut.execute()

        XCTAssertEqual(request.startCount, 1)
    }

    func testStartsReceiptRefreshOnExecuteWhenPreviousRefreshFinishedWithSuccess() {
        let request = ReceiptRefreshRequestSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: request),
            output: PurchaseRestorationUseCaseOutputSpy()
        )

        sut.execute()
        sut.didRefreshReceipt(ValidReceipt())
        sut.execute()

        XCTAssertEqual(request.startCount, 2)
    }

    func testStartsReceiptRefreshOnExecuteWhenPreviousRefreshFinishedWithFailure() {
        let request = ReceiptRefreshRequestSpy()
        let sut = PurchaseRestorationUseCase(
            factory: ReceiptRefreshRequestFactoryStub(request: request),
            output: PurchaseRestorationUseCaseOutputSpy()
        )

        sut.execute()
        sut.didFailRefreshingReceipt(error: "any")
        sut.execute()

        XCTAssertEqual(request.startCount, 2)
    }
}

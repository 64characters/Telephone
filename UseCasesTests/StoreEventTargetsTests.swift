//
//  StoreEventTargetsTests.swift
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

import Testing
import UseCases
import UseCasesTestDoubles

@MainActor
struct StoreEventTargetsTests {
    @Test func callsDidStartPurchasingProductWithPassedArgumentOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets(targets: [first, second])
        let identifier = "any"

        sut.didStartPurchasingProduct(withIdentifier: identifier)

        #expect(first.didCallDidStartPurchasing)
        #expect(first.invokedIdentifier == identifier)
        #expect(second.didCallDidStartPurchasing)
        #expect(second.invokedIdentifier == identifier)
    }

    @Test func callsDidPurchaseOnAllTargets() async {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets(targets: [first, second])

        await sut.didPurchase()

        #expect(first.didCallDidPurchase)
        #expect(second.didCallDidPurchase)
    }

    @Test func callsDidFailPurchasingWithPassedArgumentOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets(targets: [first, second])
        let error = "any"

        sut.didFailPurchasing(error: error)

        #expect(first.didCallDidFailPurchasing)
        #expect(first.invokedError == error)
        #expect(second.didCallDidFailPurchasing)
        #expect(second.invokedError == error)
    }

    @Test func callsDidCancelPurchasingOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets(targets: [first, second])

        sut.didCancelPurchasing()

        #expect(first.didCallDidCancelPurchasing)
        #expect(second.didCallDidCancelPurchasing)
    }

    @Test func callsDidRestorePurchasesOnAllTargets() async {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets(targets: [first, second])

        await sut.didRestorePurchases()

        #expect(first.didCallDidRestore)
        #expect(second.didCallDidRestore)
    }

    @Test func callsDidFailRestoringPurchasesWithPassedArgumentOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets(targets: [first, second])
        let error = "any"

        sut.didFailRestoringPurchases(error: error)

        #expect(first.didCallDidFailRestoring)
        #expect(first.invokedError == error)
        #expect(second.didCallDidFailRestoring)
        #expect(second.invokedError == error)
    }

    @Test func callsDidCancelRestoringPurchasesOnAllTargets() {
        let first = StoreEventTargetSpy()
        let second = StoreEventTargetSpy()
        let sut = StoreEventTargets(targets: [first, second])

        sut.didCancelRestoringPurchases()

        #expect(first.didCallDidCancelRestoring)
        #expect(second.didCallDidCancelRestoring)
    }
}

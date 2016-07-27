//
//  PurchaseRestorationUseCase.swift
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

public protocol PurchaseRestorationUseCaseOutput {
    func didRestorePurchases()
    func didFailRestoringPurchases(error error: String)
}

public final class PurchaseRestorationUseCase {
    private var request: ReceiptRefreshRequest?
    private let factory: ReceiptRefreshRequestFactory
    private let output: PurchaseRestorationUseCaseOutput

    public init(factory: ReceiptRefreshRequestFactory, output: PurchaseRestorationUseCaseOutput) {
        self.factory = factory
        self.output = output
    }
}

extension PurchaseRestorationUseCase: UseCase {
    public func execute() {
        guard request == nil else { return }
        request = factory.create(target: self)
        request!.start()
    }
}

extension PurchaseRestorationUseCase: ReceiptRefreshRequestTarget {
    public func didRefreshReceipt(receipt: Receipt) {
        receipt.validate { result in
            self.notifyOutputAfterRefreshOf(receipt, result: result)
        }
        request = nil
    }

    public func didFailRefreshingReceipt(error error: String) {
        output.didFailRestoringPurchases(error: error)
        request = nil
    }

    private func notifyOutputAfterRefreshOf(receipt: Receipt, result: ReceiptValidationResult) {
        if result == .ReceiptIsValid {
            output.didRestorePurchases()
        } else {
            output.didFailRestoringPurchases(error: result.message)
        }
    }
}

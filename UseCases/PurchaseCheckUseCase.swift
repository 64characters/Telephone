//
//  PurchaseCheckUseCase.swift
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

import Foundation

public protocol PurchaseCheckUseCaseOutput {
    func didCheckPurchase(expiration expiration: NSDate)
    func didFailCheckingPurchase()
}

public class PurchaseCheckUseCase {
    private let receipt: Receipt
    private let output: PurchaseCheckUseCaseOutput

    public init(receipt: Receipt, output: PurchaseCheckUseCaseOutput) {
        self.receipt = receipt
        self.output = output
    }
}

extension PurchaseCheckUseCase: UseCase {
    public func execute() {
        receipt.validate(completion: notifyOutput)
    }

    private func notifyOutput(withResult result: ReceiptValidationResult) {
        switch result {
        case .ReceiptIsValid(expiration: let expiration):
            output.didCheckPurchase(expiration: expiration)
        default:
            output.didFailCheckingPurchase()
        }
    }
}

//
//  ReceiptRefreshRequestFactoryStub.swift
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

final class ReceiptRefreshRequestFactoryStub {
    private var attempts = 0
}

extension ReceiptRefreshRequestFactoryStub: ReceiptRefreshRequestFactory {
    func create(target target: ReceiptRefreshRequestTarget) -> ReceiptRefreshRequest {
        attempts += 1
        if attempts % 4 == 0 {
            return ReceiptRefreshRequestStub(receipt: ValidReceipt(), target: target)
        } else if attempts % 3 == 0 {
            return ReceiptRefreshRequestStub(receipt: NoActivePurchasesReceipt(), target: target)
        } else if attempts % 2 == 0 {
            return ReceiptRefreshRequestStub(receipt: InvalidReceipt(), target: target)
        } else {
            return FailingReceiptRefreshRequestStub(target: target)
        }
    }
}

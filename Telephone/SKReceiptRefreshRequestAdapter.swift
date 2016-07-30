//
//  SKReceiptRefreshRequestAdapter.swift
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

import StoreKit
import UseCases

final class SKReceiptRefreshRequestAdapter: NSObject {
    private let request = SKReceiptRefreshRequest()
    private let receipt: Receipt
    private let target: ReceiptRefreshRequestTarget

    init(receipt: Receipt, target: ReceiptRefreshRequestTarget) {
        self.receipt = receipt
        self.target = target
        super.init()
        request.delegate = self
    }

    deinit {
        request.cancel()
    }
}

extension SKReceiptRefreshRequestAdapter: ReceiptRefreshRequest {
    func start() {
        request.start()
    }
}

extension SKReceiptRefreshRequestAdapter: SKRequestDelegate {
    func requestDidFinish(request: SKRequest) {
        dispatch_async(dispatch_get_main_queue()) {
            self.target.didRefreshReceipt(self.receipt)
        }
    }

    func request(request: SKRequest, didFailWithError error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.target.didFailRefreshingReceipt(error: descriptionOf(error))
        }
    }
}

private func descriptionOf(error: NSError?) -> String {
    return error?.localizedDescription ?? localizedUnknownError()
}

private func localizedUnknownError() -> String {
    return NSLocalizedString("Unknown error", comment: "Unknown error.")
}

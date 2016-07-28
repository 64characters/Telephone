//
//  ReceiptXPCGateway.swift
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
import ReceiptValidation
import UseCases

final class ReceiptXPCGateway {
    private let connection: NSXPCConnection

    init() {
        connection = NSXPCConnection(serviceName: "com.tlphn.Telephone.ReceiptValidation")
        connection.remoteObjectInterface = NSXPCInterface(withProtocol: ReceiptValidation.self)
        connection.resume()
    }

    deinit {
        connection.invalidate()
    }

    func validateReceipt(receipt: NSData, completion: (ReceiptValidationResult) -> Void) {
        createValidation(completion: completion).validateReceipt(receipt) { result in handle(result, completion: completion) }
    }

    private func createValidation(completion completion: (ReceiptValidationResult) -> Void) -> ReceiptValidation {
        return connection.remoteObjectProxyWithErrorHandler { error in handleError(completion) } as! ReceiptValidation
    }
}

private func handle(result: Result, completion: (ReceiptValidationResult) -> Void) {
    dispatch_async(dispatch_get_main_queue()) { handleOnMain(result, completion: completion) }
}

private func handleOnMain(result: Result, completion: (ReceiptValidationResult) -> Void) {
    switch result {
    case .ReceiptIsValid:
        completion(.ReceiptIsValid)
    case .ReceiptIsInvalid:
        completion(.ReceiptIsInvalid)
    case .NoActivePurchases:
        completion(.NoActivePurchases)
    }
}

private func handleError(completion: (ReceiptValidationResult) -> Void) {
    dispatch_async(dispatch_get_main_queue()) { completion(.ReceiptIsInvalid) }
}

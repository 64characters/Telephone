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
        validation(completion: completion).validateReceipt(receipt) { result, expiration in
            didValidateReceipt(with: result, expiration: expiration, completion: completion)
        }
    }

    private func validation(completion completion: (ReceiptValidationResult) -> Void) -> ReceiptValidation {
        return connection.remoteObjectProxyWithErrorHandler { error in
            didFailReceiptValidation(completion)
            } as! ReceiptValidation
    }
}

private func didValidateReceipt(with result: Result, expiration: NSDate, completion: (ReceiptValidationResult) -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        didValidateReceiptOnMain(with: result, expiration: expiration, completion: completion)
    }
}

private func didFailReceiptValidation(completion: (ReceiptValidationResult) -> Void) {
    dispatch_async(dispatch_get_main_queue()) { completion(.ReceiptIsInvalid) }
}

private func didValidateReceiptOnMain(with result: Result, expiration: NSDate, completion: (ReceiptValidationResult) -> Void) {
    switch result {
    case .ReceiptIsValid:
        completion(.ReceiptIsValid)
    case .ReceiptIsInvalid:
        completion(.ReceiptIsInvalid)
    case .NoActivePurchases:
        completion(.NoActivePurchases)
    }
}

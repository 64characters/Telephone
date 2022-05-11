//
//  ReceiptXPCGateway.swift
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

import Foundation
import ReceiptValidation
import UseCases

final class ReceiptXPCGateway {
    private let connection: NSXPCConnection

    init() {
        connection = NSXPCConnection(serviceName: "com.tlphn.Telephone.ReceiptValidation")
        connection.remoteObjectInterface = NSXPCInterface(with: ReceiptValidation.self)
        connection.resume()
    }

    deinit {
        connection.invalidate()
    }

    func validateReceipt(_ receipt: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        validation(completion: completion).validateReceipt(receipt) { result, expiration in
            didValidateReceipt(with: result, expiration: expiration, completion: completion)
        }
    }

    private func validation(completion: @escaping (ReceiptValidationResult) -> Void) -> ReceiptValidation {
        return connection.remoteObjectProxyWithErrorHandler { error in
            didFailReceiptValidation(completion)
            } as! ReceiptValidation
    }
}

private func didValidateReceipt(with result: Result, expiration: Date, completion: @escaping (ReceiptValidationResult) -> Void) {
    DispatchQueue.main.async { handleDidValidateReceiptOnMain(result: result, expiration: expiration, completion: completion) }
}

private func didFailReceiptValidation(_ completion: @escaping (ReceiptValidationResult) -> Void) {
    DispatchQueue.main.async { completion(.receiptIsInvalid) }
}

private func handleDidValidateReceiptOnMain(result: Result, expiration: Date, completion: (ReceiptValidationResult) -> Void) {
    switch result {
    case .receiptIsValid:
        completion(.receiptIsValid(expiration: expiration))
    case .receiptIsInvalid:
        completion(.receiptIsInvalid)
    case .noActivePurchases:
        completion(.noActivePurchases)
    }
}

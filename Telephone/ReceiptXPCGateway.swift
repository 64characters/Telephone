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

final class ReceiptXPCGateway: Sendable {
    private nonisolated(unsafe) let connection: NSXPCConnection

    init() {
        connection = NSXPCConnection(serviceName: "com.tlphn.Telephone.ReceiptValidation")
        connection.remoteObjectInterface = NSXPCInterface(with: ReceiptValidation.self)
        connection.resume()
    }

    deinit {
        connection.invalidate()
    }

    func validateReceipt(_ receipt: Data) async -> ReceiptValidationResult {
        await withCheckedContinuation { continuation in
            validation(completion: { continuation.resume(returning: $0) }).validateReceipt(receipt) { result, expiration in
                switch result {
                case .receiptIsValid:
                    continuation.resume(returning: .receiptIsValid(expiration: expiration))
                case .receiptIsInvalid:
                    continuation.resume(returning: .receiptIsInvalid)
                case .noActivePurchases:
                    continuation.resume(returning: .noActivePurchases)
                }
            }
        }
    }

    private func validation(completion: @escaping (ReceiptValidationResult) -> Void) -> ReceiptValidation {
        return connection.remoteObjectProxyWithErrorHandler { _ in
            completion(.receiptIsInvalid)
        } as! ReceiptValidation
    }
}

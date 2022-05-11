//
//  Receipt.swift
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

public protocol Receipt {
    func validate(completion: @escaping (ReceiptValidationResult) -> Void)
}

public enum ReceiptValidationResult {
    case receiptIsValid(expiration: Date)
    case receiptIsInvalid
    case noActivePurchases

    public var localizedDescription: String {
        switch self {
        case .receiptIsValid:
            return NSLocalizedString("Receipt is valid.", bundle: bundle(), comment: "Receipt validation success.")
        case .receiptIsInvalid:
            return NSLocalizedString("Receipt is invalid.", bundle: bundle(), comment: "Receipt validation error.")
        case .noActivePurchases:
            return NSLocalizedString(
                "Receipt doesn’t contain active purchases.", bundle: bundle(), comment: "No active purchase error."
            )
        }
    }
}

private func bundle() -> Bundle {
    return Bundle(identifier: "com.tlphn.Telephone.UseCases")!
}

//
//  Receipt.swift
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

public protocol Receipt {
    func validate(completion completion: (ReceiptValidationResult) -> Void)
}

public enum ReceiptValidationResult {
    case ReceiptIsValid
    case ReceiptIsInvalid
    case NoActivePurchases

    public var message: String {
        switch self {
        case ReceiptIsValid:
            return NSLocalizedString("Receipt is valid.", comment: "Receipt validation success.")
        case .ReceiptIsInvalid:
            return NSLocalizedString("Receipt is invalid.", comment: "Receipt validation error.")
        case .NoActivePurchases:
            return NSLocalizedString("Receipt doesn’t contain active purchases.", comment: "No active purchase error.")
        }
    }
}

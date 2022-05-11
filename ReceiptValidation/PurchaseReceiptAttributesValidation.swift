//
//  PurchaseReceiptAttributesValidation.swift
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

final class PurchaseReceiptAttributesValidation: NSObject {
    private let identifiers: Set<String>

    init(identifiers: Set<String>) {
        self.identifiers = identifiers
    }
}

extension PurchaseReceiptAttributesValidation: ReceiptValidation {
    func validateReceipt(_ receipt: Data, completion: (_ result: Result, _ expiration: Date) -> Void) {
        if let r = purchaseReceipts(from: receipt).max(by: hasEarlierExpirationDate), isValid(r) {
            completion(.receiptIsValid, r.expiration)
        } else {
            completion(.noActivePurchases, Date.distantPast)
        }
    }

    private func purchaseReceipts(from receipt: Data) -> [ASN1PurchaseReceipt] {
        return ASN1PurchaseReceipts(payload: ASN1ReceiptPayload(container: PKCS7Container(data: receipt)!)!).filter(hasExpectedID)
    }

    private func hasExpectedID(_ receipt: ASN1PurchaseReceipt) -> Bool {
        return identifiers.contains(receipt.identifier)
    }
}

private func hasEarlierExpirationDate(_ lhs: ASN1PurchaseReceipt, _ rhs: ASN1PurchaseReceipt) -> Bool {
    return lhs.expiration < rhs.expiration
}

private func isValid(_ receipt: ASN1PurchaseReceipt) -> Bool {
    return !receipt.isCancelled && oneMonth(after: receipt.expiration) >= Date()
}

private func oneMonth(after date: Date) -> Date {
    return date.addingTimeInterval(60 * 60 * 24 * 30)
}

//
//  PurchaseReceiptAttributesValidation.swift
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

final class PurchaseReceiptAttributesValidation: NSObject {
    fileprivate let identifiers: Set<String>

    init(identifiers: Set<String>) {
        self.identifiers = identifiers
    }
}

extension PurchaseReceiptAttributesValidation: ReceiptValidation {
    func validateReceipt(_ receipt: Data, completion: (_ result: Result, _ expiration: Date) -> Void) {
        if let expiration = latestExpirationOfValidPurchaseReceipts(from: receipt) {
            completion(.receiptIsValid, expiration)
        } else {
            completion(.noActivePurchases, Date.distantPast)
        }
    }

    private func latestExpirationOfValidPurchaseReceipts(from receipt: Data) -> Date? {
        return validPurchaseReceipts(from: receipt).max(by: hasEarlierExpirationDate)?.expiration
    }

    private func validPurchaseReceipts(from receipt: Data) -> [ASN1PurchaseReceipt] {
        return ASN1PurchaseReceipts(payload: ASN1ReceiptPayload(container: PKCS7Container(data: receipt)!)!).filter(isReceiptValid)
    }

    private func isReceiptValid(_ receipt: ASN1PurchaseReceipt) -> Bool {
        return !receipt.isCancelled && sixMonths(after: receipt.expiration) >= Date() && identifiers.contains(receipt.identifier)
    }
}

private func hasEarlierExpirationDate(_ lhs: ASN1PurchaseReceipt, _ rhs: ASN1PurchaseReceipt) -> Bool {
    return lhs.expiration < rhs.expiration
}

private func sixMonths(after date: Date) -> Date {
    return date.addingTimeInterval(60 * 60 * 24 * 30 * 6)
}

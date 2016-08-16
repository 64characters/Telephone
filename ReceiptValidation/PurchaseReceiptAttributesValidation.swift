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
    private let identifiers: Set<String>

    init(identifiers: Set<String>) {
        self.identifiers = identifiers
    }
}

extension PurchaseReceiptAttributesValidation: ReceiptValidation {
    func validateReceipt(receipt: NSData, completion: (result: Result, expiration: NSDate) -> Void) {
        if let expiration = latestExpirationOfValidPurchaseReceipts(from: receipt) {
            completion(result: .ReceiptIsValid, expiration: expiration)
        } else {
            completion(result: .NoActivePurchases, expiration: NSDate.distantPast())
        }
    }

    private func latestExpirationOfValidPurchaseReceipts(from receipt: NSData) -> NSDate? {
        return validPurchaseReceipts(from: receipt).maxElement(hasEarlierExpirationDate)?.expiration
    }

    private func validPurchaseReceipts(from receipt: NSData) -> [ASN1PurchaseReceipt] {
        return ASN1PurchaseReceipts(payload: ASN1ReceiptPayload(container: PKCS7Container(data: receipt)!)!).filter(isReceiptValid)
    }

    private func isReceiptValid(receipt: ASN1PurchaseReceipt) -> Bool {
        return !receipt.isCancelled && isLaterThanNow(receipt.expiration) && identifiers.contains(receipt.identifier)
    }
}

private func isLaterThanNow(date: NSDate) -> Bool {
    return date.laterDate(NSDate()) == date
}

private func hasEarlierExpirationDate(lhs: ASN1PurchaseReceipt, _ rhs: ASN1PurchaseReceipt) -> Bool {
    return lhs.expiration.earlierDate(rhs.expiration) == lhs.expiration
}

//
//  ReceiptAttributesValidation.swift
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

final class ReceiptAttributesValidation: NSObject {
    fileprivate let origin: ReceiptValidation
    fileprivate let attributes: ReceiptAttributes

    init(origin: ReceiptValidation, attributes: ReceiptAttributes) {
        self.origin = origin
        self.attributes = attributes
    }
}

extension ReceiptAttributesValidation: ReceiptValidation {
    func validateReceipt(_ receipt: Data, completion: (_ result: Result, _ expiration: Date) -> Void) {
        if let p = ASN1ReceiptPayload(container: PKCS7Container(data: receipt)!), isReceiptValid(ASN1Receipt(payload: p)) {
            origin.validateReceipt(receipt, completion: completion)
        } else {
            completion(.receiptIsInvalid, Date.distantPast)
        }
    }

    private func isReceiptValid(_ r: ASN1Receipt) -> Bool {
        let c = ReceiptChecksum(guid: attributes.guid, opaque: r.opaque, identifier: r.identifierData)
        return r.identifier == attributes.identifier && r.version == attributes.version && ReceiptChecksum(sha1: r.checksum) == c
    }
}

struct ReceiptAttributes {
    let identifier: String
    let version: String
    let guid: Data
}

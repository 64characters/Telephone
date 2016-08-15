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
    private let origin: ReceiptValidation
    private let attributes: ReceiptAttributes

    init(origin: ReceiptValidation, attributes: ReceiptAttributes) {
        self.origin = origin
        self.attributes = attributes
    }
}

extension ReceiptAttributesValidation: ReceiptValidation {
    func validateReceipt(receipt: NSData, completion: (Result) -> Void) {
        if let p = ASN1ReceiptPayload(container: PKCS7Container(data: receipt)!) where isReceiptValid(ASN1Receipt(payload: p)) {
            origin.validateReceipt(receipt, completion: completion)
        } else {
            completion(.ReceiptIsInvalid)
        }
    }

    private func isReceiptValid(r: ASN1Receipt) -> Bool {
        let c = ReceiptChecksum(guid: attributes.guid, opaque: r.opaque, identifier: r.identifierData)
        return r.identifier == attributes.identifier && r.version == attributes.version && ReceiptChecksum(sha1: r.checksum) == c
    }
}

protocol ReceiptAttributes {
    var identifier: String { get }
    var version: String { get }
    var guid: NSData { get }
}

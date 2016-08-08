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
    func validateReceipt(data: NSData, completion: (Result) -> Void) {
        if let payload = ReceiptPayload(data: data) where validate(payload) {
            origin.validateReceipt(data, completion: completion)
        } else {
            completion(.ReceiptIsInvalid)
        }
    }

    private func validate(payload: ReceiptPayload) -> Bool {
        let checksum = ReceiptChecksum(GUID: attributes.guid, opaque: payload.opaque, identifier: payload.identifierData)
        return payload.identifier == attributes.identifier &&
            payload.version == attributes.version &&
            payload.checksum == checksum.dataValue
    }
}

protocol ReceiptAttributes {
    var identifier: String { get }
    var version: String { get }
    var guid: NSData { get }
}

//
//  ASN1Receipt.swift
//  Telephone
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

struct ASN1Receipt {
    let identifier: String
    let identifierData: Data
    let opaque: Data
    let checksum: Data

    init(payload: ASN1ReceiptPayload) {
        var identifier: String?
        var identifierData: Data?
        var opaque: Data?
        var checksum: Data?
        for attribute in payload.attributes {
            switch attribute.type {
            case identifierType:
                identifier = String(ASN1UTF8String: attribute.value)
                identifierData = attribute.value
            case opaqueType:
                opaque = attribute.value
            case checksumType:
                checksum = attribute.value
            default:
                break
            }
        }
        self.identifier = identifier ?? ""
        self.identifierData = identifierData ?? Data()
        self.opaque = opaque ?? Data()
        self.checksum = checksum ?? Data()
    }
}

private let identifierType = 2
private let opaqueType     = 4
private let checksumType   = 5

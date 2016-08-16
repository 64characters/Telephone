//
//  ASN1ReceiptPayload.swift
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

struct ASN1ReceiptPayload {
    let attributes: [ASN1PayloadAttribute]

    init?(container: PKCS7Container) {
        guard let payload = ASN1Payload(data: container.content) else { return nil }
        attributes = payload.attributes
    }
}

//
//  ASN1PurchaseReceipts.swift
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

struct ASN1PurchaseReceipts {
    let all: [ASN1PurchaseReceipt]

    init(payload: ASN1ReceiptPayload) {
        all = payload.attributes.filter({ $0.type == purchase }).map({ ASN1PurchaseReceipt(attribute: $0) })
    }
}

extension ASN1PurchaseReceipts: SequenceType {
    func generate() -> IndexingGenerator<[ASN1PurchaseReceipt]> {
        return all.generate()
    }
}

private let purchase = 17

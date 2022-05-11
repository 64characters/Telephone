//
//  ASN1PurchaseReceipt.swift
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

import Foundation

struct ASN1PurchaseReceipt {
    let identifier: String
    let expiration: Date
    let isCancelled: Bool

    init(attribute: ASN1PayloadAttribute) {
        precondition(attribute.type == purchaseReceiptType)
        var identifier: String?
        var expiration: Date?
        var isCancelled: Bool?
        if let payload = ASN1Payload(data: attribute.value) {
            for a in payload.attributes {
                switch a.type {
                case identifierType:
                    identifier = String(ASN1UTF8String: a.value)
                case expirationType:
                    expiration = date(from: String(ASN1IA5String: a.value))
                case cancellationType:
                    isCancelled = isValidDate(String(ASN1IA5String: a.value))
                default:
                    break
                }
            }
        }
        self.identifier = identifier ?? ""
        self.expiration = expiration ?? Date.distantPast
        self.isCancelled = isCancelled ?? false
    }
}

private func date(from string: String) -> Date {
    return formatter.date(from: string) ?? Date.distantPast
}

private func isValidDate(_ string: String) -> Bool {
    return formatter.date(from: string) != nil
}

private let formatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = TimeZone(secondsFromGMT: 0)
    f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    return f
}()

private let purchaseReceiptType = 17
private let identifierType      = 1702
private let expirationType      = 1708
private let cancellationType    = 1712

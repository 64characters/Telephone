//
//  ASN1PurchaseReceipt.swift
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

struct ASN1PurchaseReceipt {
    let identifier: String
    let expiration: NSDate
    let isCancelled: Bool

    init(attribute: ASN1PayloadAttribute) {
        assert(attribute.type == purchaseReceiptType)
        var identifier = ""
        var expiration = NSDate.distantPast()
        var isCancelled = false
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
        self.identifier = identifier
        self.expiration = expiration
        self.isCancelled = isCancelled
    }
}

private func date(from string: String) -> NSDate {
    return formatter.dateFromString(string) ?? NSDate.distantPast()
}

private func isValidDate(string: String) -> Bool {
    return formatter.dateFromString(string) != nil
}

private let formatter: NSDateFormatter = {
    let f = NSDateFormatter()
    f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    f.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    return f
}()

private let purchaseReceiptType = 17
private let identifierType      = 1702
private let expirationType      = 1708
private let cancellationType    = 1712

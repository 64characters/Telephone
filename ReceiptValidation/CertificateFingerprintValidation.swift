//
//  CertificateFingerprintValidation.swift
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

final class CertificateFingerprintValidation: NSObject {
    private let origin: ReceiptValidation
    private let certificate: NSData

    init(origin: ReceiptValidation, certificate: NSData) {
        self.origin = origin
        self.certificate = certificate
    }
}

extension CertificateFingerprintValidation: ReceiptValidation {
    func validateReceipt(receipt: NSData, completion: (Result) -> Void) {
        if SHA256Fingerprint(source: certificate) == SHA256Fingerprint(sha256: expected) {
            origin.validateReceipt(receipt, completion: completion)
        } else {
            completion(.ReceiptIsInvalid)
        }
    }
}

private let bytes: [UInt8] = [
    0xb0, 0xb1, 0x73, 0x0e, 0xcb, 0xc7, 0xff, 0x45,
    0x05, 0x14, 0x2c, 0x49, 0xf1, 0x29, 0x5e, 0x6e,
    0xda, 0x6b, 0xca, 0xed, 0x7e, 0x2c, 0x68, 0xc5,
    0xbe, 0x91, 0xb5, 0xa1, 0x10, 0x01, 0xf0, 0x24
]

private let expected = NSData(bytes: bytes, length: bytes.count)

//
//  CertificateFingerprintValidation.swift
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

final class CertificateFingerprintValidation: NSObject {
    private let origin: ReceiptValidation
    private let certificate: Data

    init(origin: ReceiptValidation, certificate: Data) {
        self.origin = origin
        self.certificate = certificate
    }
}

extension CertificateFingerprintValidation: ReceiptValidation {
    func validateReceipt(_ receipt: Data, completion: @escaping (_ result: Result, _ expiration: Date) -> Void) {
        if SHA256Fingerprint(source: certificate) == SHA256Fingerprint(sha256: expected) {
            origin.validateReceipt(receipt, completion: completion)
        } else {
            completion(.receiptIsInvalid, Date.distantPast)
        }
    }
}

private let expected = Data(
    [
        0xb0, 0xb1, 0x73, 0x0e, 0xcb, 0xc7, 0xff, 0x45,
        0x05, 0x14, 0x2c, 0x49, 0xf1, 0x29, 0x5e, 0x6e,
        0xda, 0x6b, 0xca, 0xed, 0x7e, 0x2c, 0x68, 0xc5,
        0xbe, 0x91, 0xb5, 0xa1, 0x10, 0x01, 0xf0, 0x24
    ]
)

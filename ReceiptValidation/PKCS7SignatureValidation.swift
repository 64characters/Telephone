//
//  PKCS7SignatureValidation.swift
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

final class PKCS7SignatureValidation: NSObject {
    private let origin: ReceiptValidation
    private let certificate: NSData

    init(origin: ReceiptValidation, certificate: NSData) {
        self.origin = origin
        self.certificate = certificate
    }
}

extension PKCS7SignatureValidation: ReceiptValidation {
    func validateReceipt(receipt: NSData, completion: (result: Result, expiration: NSDate) -> Void) {
        if PKCS7Container(data: receipt)!.isSignatureValidWithRootCertificate(certificate) {
            origin.validateReceipt(receipt, completion: completion)
        } else {
            completion(result: .ReceiptIsInvalid, expiration: NSDate.distantPast())
        }
    }
}

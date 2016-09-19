//
//  main.swift
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

let certificate = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("Certificate", withExtension: "crt")!)!
// Have to use a variable, otherwise released because NSXPCListener.delegate is unowned.
let delegate = DefaultNSXPCListenerDelegate(
    interface: ReceiptValidation.self,
    object: PKCS7ContainerValidation(
        origin: CertificateFingerprintValidation(
            origin: PKCS7SignatureValidation(
                origin: ReceiptAttributesValidation(
                    origin: PurchaseReceiptAttributesValidation(
                        identifiers: Set(["com.tlphn.Telephone.iap.month", "com.tlphn.Telephone.iap.year"])
                    ),
                    attributes: ReceiptAttributes(
                        identifier: "com.tlphn.Telephone", version: "1.2.1", guid: DeviceGUID().dataValue
                    )
                ),
                certificate: certificate
            ),
            certificate: certificate
        )
    )
)
NSXPCListener.serviceListener().delegate = delegate
NSXPCListener.serviceListener().resume()

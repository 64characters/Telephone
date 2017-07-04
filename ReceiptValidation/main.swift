//
//  main.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

let certificate = try! Data(contentsOf: Bundle.main.url(forResource: "Certificate", withExtension: "crt")!)
// Have to use a variable, otherwise released because NSXPCListener.delegate is unowned.
let delegate = DefaultNSXPCListenerDelegate(
    interface: ReceiptValidation.self,
    object: PKCS7ContainerValidation(
        origin: CertificateFingerprintValidation(
            origin: PKCS7SignatureValidation(
                origin: ReceiptAttributesValidation(
                    origin: PurchaseReceiptAttributesValidation(
                        identifiers: Set(["eu.4mk.Telephone.iap.month", "eu.4mk.Telephone.iap.year"])
                    ),
                    attributes: ReceiptAttributes(identifier: "eu.4mk.Telephone", guid: DeviceGUID().dataValue)
                ),
                certificate: certificate
            ),
            certificate: certificate
        )
    )
)
NSXPCListener.service().delegate = delegate
NSXPCListener.service().resume()

//
//  String+ASN1.swift
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

extension String {
    init(ASN1UTF8String data: NSData) {
        self.init(ASN1String: data, ASN1StringType: ASN1UTF8String, encoding: NSUTF8StringEncoding)
    }

    init(ASN1IA5String data: NSData) {
        self.init(ASN1String: data, ASN1StringType: ASN1IA5String, encoding: NSASCIIStringEncoding)
    }

    private init(ASN1String data: NSData, ASN1StringType type: UInt8, encoding: NSStringEncoding) {
        var result: String?
        let bytes = UnsafePointer<UInt8>(data.bytes)
        if bytes[0] == type {
            let length = data.length - ASN1ContentIndex
            assert(length == Int(bytes[ASN1LengthIndex]))
            result = String(data: NSData(bytes: bytes.advancedBy(ASN1ContentIndex), length: length), encoding: encoding)
        }
        self = result ?? ""
    }
}

private let ANS1TypeIndex    = 0
private let ASN1LengthIndex  = 1
private let ASN1ContentIndex = 2
private let ASN1UTF8String: UInt8 = 0x0c
private let ASN1IA5String: UInt8  = 0x16

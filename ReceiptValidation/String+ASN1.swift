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
    init(ASN1UTF8String data: Data) {
        self.init(ASN1String: data, ASN1StringType: utf8String, encoding: String.Encoding.utf8)
    }

    init(ASN1IA5String data: Data) {
        self.init(ASN1String: data, ASN1StringType: ia5String, encoding: String.Encoding.ascii)
    }

    fileprivate init(ASN1String data: Data, ASN1StringType type: UInt8, encoding: String.Encoding) {
        var result: String?
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        if bytes[typeIndex] == type {
            let length = data.count - contentIndex
            assert(length == Int(bytes[lengthIndex]))
            result = String(data: Data(bytes: UnsafePointer<UInt8>(bytes.advanced(by: contentIndex)), count: length), encoding: encoding)
        }
        self = result ?? ""
    }
}

private let typeIndex    = 0
private let lengthIndex  = 1
private let contentIndex = 2
private let utf8String: UInt8 = 0x0c
private let ia5String: UInt8  = 0x16

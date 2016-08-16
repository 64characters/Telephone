//
//  ReceiptChecksum.swift
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

struct ReceiptChecksum {
    private let sha1: NSData

    init(sha1: NSData) {
        self.sha1 = sha1
    }

    init(guid: NSData, opaque: NSData, identifier: NSData) {
        let source = NSMutableData()
        source.appendData(guid)
        source.appendData(opaque)
        source.appendData(identifier)
        self.init(sha1: digest(of: source))
    }
}

extension ReceiptChecksum: Hashable {
    var hashValue: Int {
        return sha1.hashValue
    }
}

func ==(lhs: ReceiptChecksum, rhs: ReceiptChecksum) -> Bool {
    return lhs.sha1 == rhs.sha1
}

private func digest(of source: NSData) -> NSData {
    let digest = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
    CC_SHA1(source.bytes, CC_LONG(source.length), UnsafeMutablePointer<UInt8>(digest.bytes))
    return digest
}

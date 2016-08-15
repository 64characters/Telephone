//
//  SHA256Fingerprint.swift
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

struct SHA256Fingerprint {
    private let sha256: NSData

    init(sha256: NSData) {
        self.sha256 = sha256
    }

    init(source: NSData) {
        self.init(sha256: digest(of: source))
    }
}

extension SHA256Fingerprint: Hashable {
    var hashValue: Int {
        return sha256.hashValue
    }
}

func ==(lhs: SHA256Fingerprint, rhs: SHA256Fingerprint) -> Bool {
    return lhs.sha256 == rhs.sha256
}

private func digest(of source: NSData) -> NSData {
    let digest = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))!
    CC_SHA256(source.bytes, CC_LONG(source.length), UnsafeMutablePointer<UInt8>(digest.bytes))
    return digest
}

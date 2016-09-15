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
    fileprivate let sha256: Data

    init(sha256: Data) {
        self.sha256 = sha256
    }

    init(source: Data) {
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

private func digest(of source: Data) -> Data {
    var result = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    source.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Void in
        CC_SHA256(ptr, CC_LONG(source.count), &result)
    }
    return Data(bytes: result)
}

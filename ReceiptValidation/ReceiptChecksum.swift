//
//  ReceiptChecksum.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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
    fileprivate let sha1: Data

    init(sha1: Data) {
        self.sha1 = sha1
    }

    init(guid: Data, opaque: Data, identifier: Data) {
        var source = Data()
        source.append(guid)
        source.append(opaque)
        source.append(identifier)
        self.init(sha1: digest(of: source))
    }
}

extension ReceiptChecksum: Hashable {
    var hashValue: Int {
        return sha1.hashValue
    }
}

extension ReceiptChecksum: Equatable {
    static func ==(lhs: ReceiptChecksum, rhs: ReceiptChecksum) -> Bool {
        return lhs.sha1 == rhs.sha1
    }
}

private func digest(of source: Data) -> Data {
    var result = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    source.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Void in
        CC_SHA1(ptr, CC_LONG(source.count), &result)
    }
    return Data(bytes: result)
}

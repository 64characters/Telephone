//
//  ReceiptChecksumTests.swift
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

import XCTest

final class ReceiptChecksumTests: XCTestCase {
    func testCanCreate() {
        XCTAssertNotNil(ReceiptChecksum(sha1: Data()))
    }

    func testComputesSHA1FromConcatenatedArguments() {
        // $ echo -n c00010ffb105f00d000ff1ce | xxd -r -p | sha1sum -b | xxd -r -p | xxd -i
        XCTAssertEqual(
            ReceiptChecksum(
                guid: Data([0xc0, 0x00, 0x10, 0xff]),
                opaque: Data([0xb1, 0x05, 0xf0, 0x0d]),
                identifier: Data([0x00, 0x0f, 0xf1, 0xce])
            ),
            ReceiptChecksum(
                sha1: Data(
                    [
                        0xfa, 0x47, 0x40, 0x18, 0x26, 0xc2, 0xe9, 0x76, 0x2e, 0xfa, 0x88, 0xe3,
                        0xa1, 0x96, 0x61, 0x74, 0x5f, 0xc8, 0x35, 0xbf
                    ]
                )
            )
        )
        // $ echo -n 000102030405060708090a0b0c0d0e0f | xxd -r -p | sha1sum -b | xxd -r -p | xxd -i
        XCTAssertEqual(
            ReceiptChecksum(
                guid: Data([0x00, 0x01, 0x02, 0x03, 0x04]),
                opaque: Data([0x05, 0x06, 0x07, 0x08]),
                identifier: Data([0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f])
            ),
            ReceiptChecksum(
                sha1: Data(
                    [
                        0x56, 0x17, 0x8b, 0x86, 0xa5, 0x7f, 0xac, 0x22, 0x89, 0x9a, 0x99, 0x64,
                        0x18, 0x5c, 0x2c, 0xc9, 0x6e, 0x7d, 0xa5, 0x89
                    ]
                )
            )
        )
        // $ echo -n "" | sha1sum | xxd -r -p | xxd -i
        XCTAssertEqual(
            ReceiptChecksum(guid: Data(), opaque: Data(), identifier: Data()),
            ReceiptChecksum(
                sha1: Data(
                    [
                        0xda, 0x39, 0xa3, 0xee, 0x5e, 0x6b, 0x4b, 0x0d, 0x32, 0x55, 0xbf, 0xef,
                        0x95, 0x60, 0x18, 0x90, 0xaf, 0xd8, 0x07, 0x09
                    ]
                )
            )
        )
    }
}

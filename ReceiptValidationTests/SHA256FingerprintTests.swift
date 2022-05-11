//
//  SHA256FingerprintTests.swift
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

final class SHA256FingerprintTests: XCTestCase {
    func testComputesSHA256FromSource() {
        // $ echo -n a1b2c3d4 | xxd -r -p | sha256sum -b | xxd -r -p | xxd -i
        XCTAssertEqual(
            SHA256Fingerprint(source: Data([0xa1, 0xb2, 0xc3, 0xd4])),
            SHA256Fingerprint(
                sha256: Data(
                    [
                        0x97, 0xed, 0x8e, 0x55, 0x51, 0x9b, 0x02, 0x0c, 0x4d, 0x9a, 0xce, 0xb4,
                        0x0e, 0x0d, 0x3b, 0xc7, 0xea, 0xa2, 0x2d, 0x08, 0x0d, 0x49, 0x59, 0x2b,
                        0xf2, 0x12, 0x06, 0xcb, 0x69, 0x7c, 0x8a, 0x58
                    ]
                )
            )
        )
        // $ echo -n feedc0de | xxd -r -p | sha256sum -b | xxd -r -p | xxd -i
        XCTAssertEqual(
            SHA256Fingerprint(source: Data([0xfe, 0xed, 0xc0, 0xde])),
            SHA256Fingerprint(
                sha256: Data(
                    [
                        0x59, 0xfb, 0x92, 0x0d, 0x68, 0x49, 0xa1, 0x72, 0x7f, 0x65, 0x8a, 0xcb,
                        0x47, 0x93, 0x52, 0xd4, 0x64, 0x41, 0xe8, 0x28, 0x39, 0x36, 0x52, 0x48,
                        0x20, 0x9d, 0x86, 0x19, 0xd7, 0x8f, 0x98, 0x6e
                    ]
                )
            )
        )
        // $ echo -n "" | sha256sum | xxd -r -p | xxd -i
        XCTAssertEqual(
            SHA256Fingerprint(source: Data()),
            SHA256Fingerprint(
                sha256: Data(
                    [
                        0xe3, 0xb0, 0xc4, 0x42, 0x98, 0xfc, 0x1c, 0x14, 0x9a, 0xfb, 0xf4, 0xc8,
                        0x99, 0x6f, 0xb9, 0x24, 0x27, 0xae, 0x41, 0xe4, 0x64, 0x9b, 0x93, 0x4c,
                        0xa4, 0x95, 0x99, 0x1b, 0x78, 0x52, 0xb8, 0x55
                    ]
                )
            )
        )
    }
}

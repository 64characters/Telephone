//
//  String+ASN1Tests.swift
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

final class String_ASN1Tests: XCTestCase {
    func testCanDecodeASN1UTF8String() {
        XCTAssertEqual(String(ASN1UTF8String: Data([0x0c, 0x07, 0x74, 0x65, 0x73, 0x74, 0x31, 0x32, 0x33])), "test123")
    }

    func testCanDecodeASN1IA5String() {
        XCTAssertEqual(String(ASN1IA5String: Data([0x16, 0x07, 0x74, 0x65, 0x73, 0x74, 0x31, 0x32, 0x33])), "test123")
    }
}

//
//  String+IPAddress.swift
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

public extension NSString {
    @objc(ak_isIPAddress)
    var isIPAddress: Bool {
        return isIP4Address || isIP6Address
    }

    @objc(ak_isIP4Address)
    var isIP4Address: Bool {
        return range(of: "^\(ip4Regex)$", options: .regularExpression).location != NSNotFound
    }

    @objc(ak_isIP6Address)
    var isIP6Address: Bool {
        return range(of: "^\(ip6Components.joined())$", options: .regularExpression).location != NSNotFound
    }
}

private let ip4Segment = #"(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"#
private let ip4Regex = #"(\#(ip4Segment)\.){3,3}\#(ip4Segment)"#
private let ip6Segment = "[0-9a-fA-F]{1,4}"
private let ip6Components = [
    "((\(ip6Segment):){7,7}\(ip6Segment)|",            // 1:2:3:4:5:6:7:8
    "(\(ip6Segment):){1,7}:|",                         // 1::, 1:2:3:4:5:6:7::
    "(\(ip6Segment):){1,6}:\(ip6Segment)|",            // 1::8, 1:2:3:4:5:6::8
    "(\(ip6Segment):){1,5}(:\(ip6Segment)){1,2}|",     // 1::7:8, 1:2:3:4:5::7:8, 1:2:3:4:5::8
    "(\(ip6Segment):){1,4}(:\(ip6Segment)){1,3}|",     // 1::6:7:8, 1:2:3:4::6:7:8, 1:2:3:4::8
    "(\(ip6Segment):){1,3}(:\(ip6Segment)){1,4}|",     // 1::5:6:7:8, 1:2:3::5:6:7:8, 1:2:3::8
    "(\(ip6Segment):){1,2}(:\(ip6Segment)){1,5}|",     // 1::4:5:6:7:8, 1:2::4:5:6:7:8, 1:2::8
    "\(ip6Segment):((:\(ip6Segment)){1,6})|",          // 1::3:4:5:6:7:8, 1::3:4:5:6:7:8, 1::8
    ":((:\(ip6Segment)){1,7}|:)|",                     // ::2:3:4:5:6:7:8, ::2:3:4:5:6:7:8, ::8, ::
    "fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|",  // fe80::7:8%eth0, fe80::7:8%1
    "::(ffff(:0{1,4}){0,1}:){0,1}\(ip4Regex)|",        // ::255.255.255.255, ::ffff:255.255.255.255, ::ffff:0:255.255.255.255
    "(\(ip6Segment):){1,4}:\(ip4Regex))"               // 2001:db8:3:4::192.0.2.33, 64:ff9b::192.0.2.33
]

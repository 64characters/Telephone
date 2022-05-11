//
//  SIPAddress.swift
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

import Foundation

public final class SIPAddress: NSObject {
    @objc public let user: String
    @objc public let host: String

    @objc public var stringValue: String {
        let h = ServiceAddress(host: host)
        return user.isEmpty ? "\(h)" : "\(user)@\(h)"
    }

    public override var description: String { return stringValue }

    @objc public init(user: String, host: String) {
        self.user = user
        self.host = host
    }

    @objc(initWithString:) public convenience init(_ string: String) {
        if let range = string.range(of: "@") {
            self.init(user: String(string[..<range.lowerBound]), host: String(string[range.upperBound...]))
        } else {
            self.init(user: "", host: string)
        }
    }

    @objc(SIPAddressWithUser:host:) public class func address(user: String, host: String) -> SIPAddress {
        return SIPAddress(user: user, host: host)
    }
}

extension SIPAddress {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let address = object as? SIPAddress else { return false }
        return isEqual(to: address)
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(user)
        hasher.combine(host)
        return hasher.finalize()
    }

    private func isEqual(to address: SIPAddress) -> Bool {
        return user == address.user && host == address.host
    }
}

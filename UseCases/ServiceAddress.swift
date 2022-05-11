//
//  ServiceAddress.swift
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

public final class ServiceAddress: NSObject {
    @objc public let host: String
    @objc public let port: String

    @objc public var stringValue: String {
        let h = host.isIP6Address ? "[\(host)]" : host
        return port.isEmpty ? h : "\(h):\(port)"
    }

    public override var description: String { return stringValue }

    @objc public init(host: String, port: String) {
        self.host = trimmingSquareBrackets(host)
        self.port = port
    }

    @objc public convenience init(host: String) {
        self.init(host: host, port: "")
    }

    @objc(initWithString:) public convenience init(_ string: String) {
        let address = beforeSemicolon(string)
        if trimmingSquareBrackets(address).isIP6Address {
            self.init(host: address)
        } else if let range = address.range(of: ":", options: .backwards) {
            self.init(host: String(address[..<range.lowerBound]), port: String(address[range.upperBound...]))
        } else {
            self.init(host: address)
        }
    }
}

extension ServiceAddress {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let address = object as? ServiceAddress else { return false }
        return isEqual(to: address)
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(host)
        hasher.combine(port)
        return hasher.finalize()
    }

    private func isEqual(to address: ServiceAddress) -> Bool {
        return host == address.host && port == address.port
    }
}

private func beforeSemicolon(_ string: String) -> String {
    if let index = string.firstIndex(of: ";") {
        return String(string[..<index])
    } else {
        return string
    }
}

private func trimmingSquareBrackets(_ string: String) -> String {
    return string.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
}

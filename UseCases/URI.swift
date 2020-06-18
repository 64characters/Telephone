//
//  URI.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2020 64 Characters
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

public final class URI: NSObject {
    @objc public let user: String
    @objc public let address: ServiceAddress
    @objc public let displayName: String
    @objc public let transport: Transport

    @objc public var host: String { return address.host }
    @objc public var port: String { return address.port }

    @objc public var stringValue: String {
        var a = user.isEmpty ? "\(address)" : "\(user)@\(address)"
        if transport == .tcp || transport == .tls {
            a.append(";transport=\(transport.stringValue)")
        }
        return displayName.isEmpty ? "sip:\(a)" : "\"\(displayName)\" <sip:\(a)>"
    }

    public override var description: String { return stringValue }

    @objc public init(user: String, address: ServiceAddress, displayName: String, transport: Transport = .udp) {
        self.user = user
        self.address = address
        self.displayName = displayName
        self.transport = transport
    }

    @objc public convenience init(user: String, host: String, displayName: String, transport: Transport = .udp) {
        self.init(user: user, address: ServiceAddress(host: host), displayName: displayName, transport: transport)
    }

    @objc public convenience init(address: ServiceAddress, transport: Transport = .udp) {
        self.init(user: "", address: address, displayName: "", transport: transport)
    }

    @objc public convenience init(host: String, port: String, transport: Transport = .udp) {
        self.init(address: ServiceAddress(host: host, port: port), transport: transport)
    }

    @objc public convenience init(host: String, transport: Transport = .udp) {
        self.init(address: ServiceAddress(host: host), transport: transport)
    }

    @objc(URIWithHost:port:transport:) public class func uri(host: String, port: String, transport: Transport) -> URI {
        return URI(host: host, port: port, transport: transport)
    }

    @objc(URIWithHost:transport:) public class func uri(host: String, transport: Transport) -> URI {
        return URI(host: host, transport: transport)
    }
}

extension URI {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let uri = object as? URI else { return false }
        return isEqual(to: uri)
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(user)
        hasher.combine(address)
        hasher.combine(displayName)
        hasher.combine(transport)
        return hasher.finalize()
    }

    private func isEqual(to uri: URI) -> Bool {
        return user == uri.user && address == uri.address && displayName == uri.displayName && transport == uri.transport
    }
}

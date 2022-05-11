//
//  AKSIPAccountKeys.swift
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

@objcMembers
class AKSIPAccountKeys: NSObject {
    static let uuid = "UUID"
    static let desc = "Description"
    static let fullName = "FullName"
    static let sipAddress = "SIPAddress"
    static let registrar = "Registrar"
    static let domain = "Domain"
    static let realm = "Realm"
    static let username = "Username"
    static let reregistrationTime = "ReregistrationTime"
    static let useProxy = "UseProxy"
    static let proxyHost = "ProxyHost"
    static let proxyPort = "ProxyPort"
    static let transport = "Transport"
    static let transportUDP = "UDP"
    static let transportTCP = "TCP"
    static let transportTLS = "TLS"
    static let ipVersion = "IPVersion"
    static let ipVersion4 = "4"
    static let ipVersion6 = "6"
    static let updateContactHeader = "UpdateContactHeader"
    static let updateViaHeader = "UpdateViaHeader"
    static let updateSDP = "UpdateSDP"
    static let useIPv6Only = "UseIPv6Only"
}

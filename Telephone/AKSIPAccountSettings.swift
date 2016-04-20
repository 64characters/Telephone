//
//  AKSIPAccountSettings.swift
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

class AKSIPAccountSettings: NSObject {
    let userAgent: AKSIPUserAgent
    let fullName: String
    let SIPAddress: String
    let registrar: String
    let realm: String
    let username: String

    init(userAgent: AKSIPUserAgent, fullName: String?, SIPAddress: String?, registrar: String?, realm: String?, username: String?) {
        self.userAgent = userAgent
        self.fullName = fullName ?? ""
        self.SIPAddress = SIPAddress ?? ""
        self.registrar = registrar ?? ""
        self.realm = realm ?? ""
        self.username = username ?? ""
    }
}

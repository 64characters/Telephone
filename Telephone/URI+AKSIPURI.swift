//
//  URI+AKSIPURI.swift
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
import UseCases

extension URI {
    @objc(initWithURI:transport:)
    convenience init(uri: AKSIPURI, transport: Transport) {
        self.init(
            user: uri.user,
            address: ServiceAddress(host: uri.host, port: uri.port > 0 ? "\(uri.port)" : ""),
            displayName: uri.displayName,
            transport: transport
        )
    }

    @objc(initWithURI:)
    convenience init(_ uri: AKSIPURI) {
        self.init(user: uri.user, host: uri.host, displayName: uri.displayName)
    }
}

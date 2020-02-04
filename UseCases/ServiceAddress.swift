//
//  ServiceAddress.swift
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

public final class ServiceAddress: NSObject {
    @objc public let host: String
    public let port: String

    @objc public init(string: String) {
        let address = beforeSemicolon(string)
        if trimmingSquareBrackets(address).isIP6Address {
            host = trimmingSquareBrackets(address)
            port = ""
        } else if let range = address.range(of: ":", options: .backwards) {
            host = trimmingSquareBrackets(String(address[..<range.lowerBound]))
            port = String(address[range.upperBound...])
        } else {
            host = trimmingSquareBrackets(address)
            port = ""
        }
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

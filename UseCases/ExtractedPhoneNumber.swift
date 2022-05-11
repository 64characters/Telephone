//
//  ExtractedPhoneNumber.swift
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

public struct ExtractedPhoneNumber {
    let value: String

    init(_ number: String, maxLength length: Int) {
        value = lastCharacters(
            of: strippingNonDigitCharacters(from: substringUpToPauseCharacters(in: number)), length: length
        )
    }
}

private func lastCharacters(of string: String, length: Int) -> String {
    if let index = string.index(string.endIndex, offsetBy: -length, limitedBy: string.startIndex) {
        return String(string[index...])
    } else {
        return string
    }
}

private func strippingNonDigitCharacters(from string: String) -> String {
    return string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
}

private func substringUpToPauseCharacters(in string: String) -> String {
    if let range = string.rangeOfCharacter(from: CharacterSet(charactersIn: ",;")) {
        return String(string[..<range.lowerBound])
    } else {
        return string
    }
}

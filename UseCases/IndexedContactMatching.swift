//
//  IndexedContactMatching.swift
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

@ContactsActor
public final class IndexedContactMatching {
    private let index: ContactMatchingIndex
    private let significantPhoneNumberLength: Int
    private let domain: String

    public nonisolated init(index: ContactMatchingIndex, significantPhoneNumberLength: Int, domain: String) {
        self.index = index
        self.significantPhoneNumberLength = significantPhoneNumberLength
        self.domain = domain
    }
}

extension IndexedContactMatching: ContactMatching {
    public func match(for uri: URI) async -> MatchedContact? {
        if let result = await emailMatch(for: uri) {
            return result
        } else {
            return await phoneNumberMatch(for: uri)
        }
    }

    private func emailMatch(for uri: URI) async -> MatchedContact? {
        return await index.contact(forEmail: NormalizedLowercasedString(email(for: uri)))
    }

    private func phoneNumberMatch(for uri: URI) async -> MatchedContact? {
        return await index.contact(forPhone: ExtractedPhoneNumber(uri.user, maxLength: significantPhoneNumberLength))
    }

    private func email(for uri: URI) -> String {
        return uri.host.isEmpty ? "\(uri.user)@\(domain)" : "\(uri.user)@\(uri.host)"
    }
}

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

public final class IndexedContactMatching {
    private lazy var length: Int = { return self.settings.significantPhoneNumberLength }()

    private let index: ContactMatchingIndex
    private let settings: ContactMatchingSettings
    private let domain: String

    public init(index: ContactMatchingIndex, settings: ContactMatchingSettings, domain: String) {
        self.index = index
        self.settings = settings
        self.domain = domain
    }
}

extension IndexedContactMatching: ContactMatching {
    public func match(for uri: URI) -> MatchedContact? {
        return emailMatch(for: uri) ?? phoneNumberMatch(for: uri)
    }

    private func emailMatch(for uri: URI) -> MatchedContact? {
        return index.contact(forEmail: NormalizedLowercasedString(email(for: uri)))
    }

    private func phoneNumberMatch(for uri: URI) -> MatchedContact? {
        return index.contact(forPhone: ExtractedPhoneNumber(uri.user, maxLength: length))
    }

    private func email(for uri: URI) -> String {
        return uri.host.isEmpty ? "\(uri.user)@\(domain)" : "\(uri.user)@\(uri.host)"
    }
}

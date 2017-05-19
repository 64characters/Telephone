//
//  IndexedContactMatching.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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
    fileprivate lazy var index: ContactMatchingIndex = { return self.factory.make(maxPhoneNumberLength: self.length) }()
    fileprivate lazy var length: Int = { return self.settings.significantPhoneNumberLength }()

    fileprivate let factory: ContactMatchingIndexFactory
    fileprivate let settings: ContactMatchingSettings

    public init(factory: ContactMatchingIndexFactory, settings: ContactMatchingSettings) {
        self.factory = factory
        self.settings = settings
    }
}

extension IndexedContactMatching: ContactMatching {
    public func match(for uri: URI) -> MatchedContact? {
        return emailMatch(for: uri) ?? phoneNumberMatch(for: uri)
    }

    private func emailMatch(for uri: URI) -> MatchedContact? {
        return index.contact(forAddress: "\(uri.user)@\(uri.host)".lowercased())
    }

    private func phoneNumberMatch(for uri: URI) -> MatchedContact? {
        return index.contact(forAddress: ExtractedPhoneNumber(uri.user, maxLength: length).value)
    }
}

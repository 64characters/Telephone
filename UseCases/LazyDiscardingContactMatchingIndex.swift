//
//  LazyDiscardingContactMatchingIndex.swift
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

public final class LazyDiscardingContactMatchingIndex {
    fileprivate lazy var origin: ContactMatchingIndex! = { return self.factory.make() }()

    fileprivate let factory: ContactMatchingIndexFactory

    public init(factory: ContactMatchingIndexFactory) {
        self.factory = factory
    }
}

extension LazyDiscardingContactMatchingIndex: ContactMatchingIndex {
    public func contact(forPhone phone: ExtractedPhoneNumber) -> MatchedContact? {
        return origin.contact(forPhone: phone)
    }

    public func contact(forEmail email: NormalizedLowercasedString) -> MatchedContact? {
        return origin.contact(forEmail: email)
    }
}

extension LazyDiscardingContactMatchingIndex: ContactsChangeEventTarget {
    public func contactsDidChange() {
        origin = nil
    }
}

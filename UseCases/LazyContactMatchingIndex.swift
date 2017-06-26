//
//  LazyContactMatchingIndex.swift
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

public final class LazyContactMatchingIndex {
    fileprivate lazy var origin: ContactMatchingIndex = { return self.factory.make(maxPhoneNumberLength: self.length) }()

    private let factory: ContactMatchingIndexFactory
    private let length: Int

    public init(factory: ContactMatchingIndexFactory, maxPhoneNumberLength length: Int) {
        self.factory = factory
        self.length = length
    }
}

extension LazyContactMatchingIndex: ContactMatchingIndex {
    public func contact(forPhone phone: ExtractedPhoneNumber) -> MatchedContact? {
        return origin.contact(forPhone: phone)
    }

    public func contact(forEmail email: NormalizedLowercasedString) -> MatchedContact? {
        return origin.contact(forEmail: email)
    }
}

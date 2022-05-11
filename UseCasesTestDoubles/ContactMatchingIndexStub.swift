//
//  ContactMatchingIndexStub.swift
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

import UseCases

public final class ContactMatchingIndexStub {
    private let contact: MatchedContact

    public init(contact: MatchedContact) {
        self.contact = contact
    }
}

extension ContactMatchingIndexStub: ContactMatchingIndex {
    public func contact(forPhone phone: ExtractedPhoneNumber) -> MatchedContact? {
        return contact
    }

    public func contact(forEmail email: NormalizedLowercasedString) -> MatchedContact? {
        return contact
    }
}

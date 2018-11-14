//
//  CallHistoryCallMakeUseCase.swift
//  Telephone
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

public final class CallHistoryCallMakeUseCase {
    private let account: Account

    public init(account: Account) {
        self.account = account
    }
}

extension CallHistoryCallMakeUseCase: ContactCallHistoryRecordGetUseCaseOutput {
    public func update(record: ContactCallHistoryRecord) {
        account.makeCall(to: URI(record: record), label: label(for: record.contact.address))
    }
}

private func label(for address: MatchedContact.Address) -> String {
    switch address {
    case let .phone(_, label), let .email(_, label):
        return label
    }
}

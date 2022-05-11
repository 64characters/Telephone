//
//  CallHistoryRecordTests.swift
//  UseCasesTests
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
import XCTest

final class CallHistoryRecordTests: XCTestCase {
    func testIdentifierContainsUserHostDateDurationIncomingFlag() {
        let user = "any-user"
        let host = "any-host"
        let date = Date()
        let duration = 10

        let sut = CallHistoryRecord(
            uri: URI(user: user, host: host, displayName: ""),
            date: date,
            duration: duration,
            isIncoming: true,
            isMissed: false
        )

        XCTAssertEqual(
            sut.identifier,
            "\(user)@\(host)|\(date.timeIntervalSinceReferenceDate)|\(duration)|\(sut.isIncoming ? 1 : 0)"
        )
    }
}

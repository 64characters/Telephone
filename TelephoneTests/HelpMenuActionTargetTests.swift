//
//  HelpMenuActionTargetTests.swift
//  TelephoneTests
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

import Foundation
import XCTest

final class HelpMenuActionTargetTests: XCTestCase {
    func testShowsLogFileInFileBrowserOnShowLogFile() {
        let url = LogFileURL(locations: ApplicationDataLocationsFake(), filename: "any")
        let browser = FileBrowserSpy()
        let sut = HelpMenuActionTarget(url: url, browser: browser)

        sut.showLogFile()

        XCTAssertEqual(browser.invokedURL, url.urlValue)
    }
}

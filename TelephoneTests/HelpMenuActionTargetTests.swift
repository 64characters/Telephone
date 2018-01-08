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
        let sut = HelpMenuActionTarget(
            logFileURL: url,
            homepageURL: URL(string: "http://homepage.local")!,
            faqURL: URL(string: "http://faq.local")!,
            fileBrowser: browser,
            webBrowser: WebBrowserSpy()
        )

        sut.showLogFile()

        XCTAssertEqual(browser.invokedURL, url.urlValue)
    }

    func testOpensHomepageInWebBrowserOnOpenHomepage() {
        let url = URL(string: "http://homepage.local")!
        let browser = WebBrowserSpy()
        let sut = HelpMenuActionTarget(
            logFileURL: LogFileURL(locations: ApplicationDataLocationsFake(), filename: "any"),
            homepageURL: url,
            faqURL: URL(string: "http://faq.local")!,
            fileBrowser: FileBrowserSpy(),
            webBrowser: browser
        )

        sut.openHomepage()

        XCTAssertEqual(browser.invokedURL, url)
    }

    func testOpensFAQInWebBrowserOnOpenFAQ() {
        let url = URL(string: "http://faq.local")!
        let browser = WebBrowserSpy()
        let sut = HelpMenuActionTarget(
            logFileURL: LogFileURL(locations: ApplicationDataLocationsFake(), filename: "any"),
            homepageURL: URL(string: "http://homepage.local")!,
            faqURL: url,
            fileBrowser: FileBrowserSpy(),
            webBrowser: browser
        )

        sut.openFAQ()

        XCTAssertEqual(browser.invokedURL, url)
    }
}

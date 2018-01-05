//
//  HelpMenuActionTarget.swift
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

import Foundation

final class HelpMenuActionTarget {
    private let logFileURL: LogFileURL
    private let homepageURL: URL
    private let faqURL: URL
    private let fileBrowser: FileBrowser
    private let webBrowser: WebBrowser

    init(logFileURL: LogFileURL, homepageURL: URL, faqURL: URL, fileBrowser: FileBrowser, webBrowser: WebBrowser) {
        self.logFileURL = logFileURL
        self.homepageURL = homepageURL
        self.faqURL = faqURL
        self.fileBrowser = fileBrowser
        self.webBrowser = webBrowser
    }

    func showLogFile() {
        fileBrowser.showFile(at: logFileURL.urlValue)
    }

    func openHomepage() {
        webBrowser.showPage(at: homepageURL)
    }

    func openFAQ() {
        webBrowser.showPage(at: faqURL)
    }
}
